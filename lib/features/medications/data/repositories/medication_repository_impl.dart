import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/adherence_dao.dart';
import '../../../../core/db/daos/medications_dao.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/guard.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/session_epoch.dart';
import '../../../../core/utils/app_date_formats.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/medication_adherence.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_form.dart';
import '../../domain/entities/medication_history_entity.dart';
import '../../domain/entities/medication_section.dart';
import '../../domain/medication_failures.dart';
import '../../domain/models/medication_detail_model.dart';
import '../../domain/models/seeded_medication_model.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../utils/medication_reminder_id.dart';
import '../datasources/medication_remote_datasource.dart';
import '../mappers/medication_mapper.dart';

/// Offline-first [MedicationRepository] backed by the local database and the API.
class MedicationRepositoryImpl implements MedicationRepository {
  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
    required this.mutationSyncManager,
    required this.notificationService,
    required this.session,
  });

  final MedicationRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;
  final MutationSyncManager mutationSyncManager;
  final NotificationService notificationService;
  final SessionEpoch session;

  static const _type = 'medication';
  static const _weekly = 'global_weekly';

  MedicationsDao get _meds => db.medicationsDao;
  AdherenceDao get _adherence => db.adherenceDao;

  /// Ids made on this phone are UUIDs; server ids have no dashes.
  static bool _isLocalId(String id) => id.contains('-');

  @override
  Future<MedicationAdherence> getCachedAdherence() async {
    final rate = await _adherence.getGlobalAdherenceRate(_weekly);
    if (rate == null) return const MedicationAdherence(rate: 0, days: []);
    final days = await _adherence.getGlobalAdherenceDays();
    return MedicationAdherence(rate: rate.rate, days: [
      for (final d in days.where((d) => d.type == _weekly))
        AdherenceDay(
            id: d.label,
            taken: d.taken ?? false,
            takenAt: DateTime.parse(d.dateTakenStr).toLocal()),
    ]);
  }

  @override
  AsyncResult<MedicationAdherence> getAdherence() => guard(() async {
        // Unsent doses would be missing from the server's numbers.
        if (!await connectivityService.isConnected ||
            await db.pendingMutationsDao.hasWaiting(entityType: _type)) {
          return getCachedAdherence();
        }
        try {
          final epoch = session.current;
          final result =
              await remoteDataSource.getAdherence(showWeekdays: true);
          session.ensure(epoch);
          await _adherence.saveGlobalAdherence(_weekly, result.rate, [
            for (final d in result.days)
              AdherenceGlobalDay(
                  dateTakenStr: d.takenAt.toIso8601String(),
                  taken: d.taken,
                  label: d.id ?? '',
                  type: _weekly),
          ]);
          return result;
        } catch (e) {
          AppLogger.w('Adherence from cache: $e');
          return getCachedAdherence();
        }
      });

  @override
  Stream<MedicationCount> watchCounts() =>
      _meds.watchAllMedications().map((rows) {
        int count(MedicationSection s) =>
            rows.where((m) => m.section == s.key).length;
        return MedicationCount(
            morning: count(MedicationSection.morning),
            afternoon: count(MedicationSection.afternoon),
            evening: count(MedicationSection.evening));
      });

  @override
  Stream<List<MedicationEntity>> watchSection(MedicationSection section) =>
      _meds
          .watchMedicationsBySection(section.key)
          .map((rows) => rows.map(MedicationMapper.toEntity).toList());

  @override
  Future<void> refreshAll() async {
    if (!await connectivityService.isConnected) return;
    await Future.wait([
      for (final s in MedicationSection.values) _refreshSection(s),
      _refreshList(),
    ]);
  }

  /// Replaces [section]'s rows with the server's, except rows with unsent changes.
  Future<void> _refreshSection(MedicationSection section) async {
    try {
      final epoch = session.current;
      final remote = await remoteDataSource.getMedicationsBySection(section.key);
      session.ensure(epoch);

      final local = (await _meds.getAllMedications())
          .where((m) => m.section == section.key);
      final byId = {for (final m in local) m.id: m};
      final waiting = await db.pendingMutationsDao.waitingIds(_type);
      final remoteIds = remote.map((m) => m.id).toSet();

      // Gone from this section only: the medication's other sections stay.
      for (final m in local) {
        if (remoteIds.contains(m.id) || waiting.contains(m.id)) continue;
        await notificationService
            .cancelReminder(medicationReminderId(m.id, section.key));
        await _meds.deleteMedicationSection(m.id, section.key);
      }

      final rows = [
        for (final m in remote)
          if (!waiting.contains(m.id))
            MedicationMapper.mergeRemoteWithLocal(m, byId[m.id], section),
      ];
      await _meds.insertMedications(rows);
      await _scheduleAlarms(rows);
    } catch (e) {
      AppLogger.w('Refreshing ${section.key} failed: $e');
    }
  }

  /// Refreshes name, dosage and purpose from the list (it has no schedules);
  /// a medication not seen before gets its sections fetched.
  Future<void> _refreshList() async {
    try {
      final epoch = session.current;
      final remote = await remoteDataSource.getAllMedications(pageSize: 100);
      session.ensure(epoch);
      final waiting = await db.pendingMutationsDao.waitingIds(_type);

      for (final id in await _meds.deleteUnknownSectionRows()) {
        await notificationService
            .cancelReminder(medicationReminderId(id, 'UNKNOWN'));
      }

      final updated = <Medication>[];
      var hasNew = false;
      for (final m in remote.rows.where((m) => !waiting.contains(m.id))) {
        final rows = await _meds.getMedicationById(m.id);
        hasNew |= rows.isEmpty;
        updated.addAll(rows.map((row) => row.copyWith(
            name: m.name, dosage: m.dosage, purpose: Value(m.purpose))));
      }
      await _meds.insertMedications(updated);
      if (hasNew) {
        await Future.wait(MedicationSection.values.map(_refreshSection));
      }
    } catch (e) {
      AppLogger.w('Refreshing the medication list failed: $e');
    }
  }

  @override
  AsyncResult<void> confirmDose(String medicationId, MedicationSection section) =>
      guard(() async {
        final now = clock.now();
        final day = AppDateFormats.yyyyMMdd.format(now);
        final row = (await _meds.getMedicationById(medicationId))
            .where((m) => m.section == section.key)
            .firstOrNull;
        // The local "taken" state and its queued sync are saved together or not at all.
        await db.transaction(() async {
          if (row != null) {
            await _meds
                .updateMedication(row.copyWith(taken: true, takenOn: Value(now)));
          }
          await _queue(medicationId, 'confirmMedication',
              {'section': section.key, 'date': day});
          await _adherence.markMedicationLogAsTakenOffline(
              const Uuid().v4(), medicationId, now);
          await _adherence.markGlobalDayAsTakenOffline(day);
        });
        mutationSyncManager.triggerSync();
      });

  @override
  Stream<List<MedicationEntity>> watchAll() =>
      _meds.watchAllMedications().map((rows) {
        final unique = <String, MedicationEntity>{};
        for (final row in rows) {
          unique.putIfAbsent(row.id, () => MedicationMapper.toEntity(row));
        }
        return unique.values.toList();
      });

  @override
  AsyncResult<MedicationDetailModel> getMedicationById(String id) =>
      guard(() async {
        final rows = await _meds.getMedicationById(id);
        final local =
            rows.isEmpty ? null : MedicationMapper.toDetailModel(rows.first);
        if (_isLocalId(id) ||
            await db.pendingMutationsDao.hasWaiting(entityId: id) ||
            !await connectivityService.isConnected) {
          if (local != null) return local;
          throw _isLocalId(id) ? const NotFoundFailure() : const NetworkFailure();
        }
        try {
          final epoch = session.current;
          final remote = await remoteDataSource.getMedicationById(id);
          session.ensure(epoch);
          for (final row in rows) {
            await _meds.updateMedication(row.copyWith(
              morningJson: Value(MedicationMapper.encodeSchedule(remote.morning)),
              afternoonJson:
                  Value(MedicationMapper.encodeSchedule(remote.afternoon)),
              eveningJson: Value(MedicationMapper.encodeSchedule(remote.evening)),
            ));
          }
          return remote;
        } catch (_) {
          if (local != null) return local;
          rethrow;
        }
      });

  @override
  AsyncResult<MedicationHistoryEntity> getMedicationHistory(
          String medicationId, DateTime month) =>
      guard(() async {
        if (!_isLocalId(medicationId) &&
            await connectivityService.isConnected &&
            !await db.pendingMutationsDao.hasWaiting(entityId: medicationId)) {
          try {
            final epoch = session.current;
            final result = await remoteDataSource.getMedicationHistory(
                medicationId,
                date: AppDateFormats.yyyyMM15.format(month));
            session.ensure(epoch);
            await _adherence.saveMedicationLogs([
              for (final l in result.logs)
                MedicationLog(
                    id: l.id,
                    medicationId: medicationId,
                    takenAt: l.takenAt,
                    taken: l.taken),
            ]);
            return result;
          } catch (e) {
            AppLogger.w('History from the phone: $e');
          }
        }
        // Offline: only the requested month, like the server returns.
        final logs = (await _adherence.getLogsForMedication(medicationId))
            .where((l) =>
                l.takenAt.year == month.year && l.takenAt.month == month.month)
            .toList();
        final taken = logs.where((l) => l.taken).length;
        return MedicationHistoryEntity(
          medicationName:
              (await _meds.getMedicationById(medicationId)).firstOrNull?.name ??
                  '',
          adherenceRate: logs.isEmpty ? 0 : (taken / logs.length * 100).round(),
          logs: [
            for (final l in logs)
              MedicationLogEntity(id: l.id, taken: l.taken, takenAt: l.takenAt),
          ],
        );
      });

  @override
  AsyncResult<String> createMedication(MedicationForm form) => guard(() async {
        if (form.problem case final problem?) throw problem;
        String norm(String s) => s.trim().toLowerCase();
        final existing = await _meds.getAllMedications();
        if (existing.any((m) =>
            norm(m.name) == norm(form.name) &&
            norm(m.dosage) == norm(form.dosage))) {
          throw const DuplicateMedicationFailure();
        }
        final id = const Uuid().v4();
        final rows = MedicationMapper.rowsFor(id, form);
        await db.transaction(() async {
          await _meds.insertMedications(rows);
          await _queue(id, 'createMedication',
              MedicationMapper.toCreateModel(form).toJson());
        });
        await _scheduleAlarms(rows);
        mutationSyncManager.triggerSync();
        return id;
      });

  @override
  AsyncResult<void> updateMedication(String id, MedicationForm form) =>
      guard(() async {
        if (form.problem case final problem?) throw problem;
        final previous = await _meds.getMedicationById(id);
        final rows = MedicationMapper.rowsFor(id, form, previous: previous);
        await db.transaction(() async {
          if (previous.isNotEmpty) {
            await _meds.deleteMedication(id);
            await _meds.insertMedications(rows);
          }
          await _queue(id, 'updateMedication',
              MedicationMapper.toUpdateModel(form).toJson());
        });
        if (previous.isNotEmpty) {
          await _cancelAlarms(id);
          await _scheduleAlarms(rows);
        }
        mutationSyncManager.triggerSync();
      });

  @override
  AsyncResult<void> deleteMedication(String id) => guard(() async {
        await db.transaction(() async {
          await _meds.deleteMedication(id);
          await _queue(id, 'deleteMedication', const {});
        });
        await _cancelAlarms(id);
        mutationSyncManager.triggerSync();
      });

  @override
  Future<List<SeededMedicationModel>> searchPreloaded(String search) async =>
      (await _meds.searchPreloadedMedications(search))
          .map(MedicationMapper.toSeededMedication)
          .toList();

  @override
  Stream<void> get onSynced =>
      mutationSyncManager.onMutationSynced.where((e) => e.contains(_type));

  /// The sync manager reports id changes as `remap:medication:<old>:<new>`.
  @override
  Stream<(String, String)> get onIdChanged =>
      mutationSyncManager.onMutationSynced
          .map((e) => e.split(':'))
          .where((p) => p.length == 4 && p[0] == 'remap' && p[1] == _type)
          .map((p) => (p[2], p[3]));

  @override
  Future<void> syncLocalAlarms() async {
    await notificationService.cancelAllReminders();
    await _scheduleAlarms(await _meds.getAllMedications());
  }

  @override
  Future<void> moveReminders(String oldId, String newId) async {
    await _cancelAlarms(oldId);
    await _cancelAlarms(newId);
    await _scheduleAlarms(await _meds.getMedicationById(newId));
  }

  Future<void> _queue(
          String id, String action, Map<String, dynamic> payload) =>
      db.pendingMutationsDao.queueMutation(
          entityId: id, entityType: _type, action: action, payload: payload);

  Future<void> _scheduleAlarms(List<Medication> rows) async {
    for (final m in rows.where((m) => m.toBeTakenAt != null)) {
      await notificationService.scheduleDailyReminder(
        id: medicationReminderId(m.id, m.section),
        title: 'Time for your medication!',
        body: 'It is time to take ${m.dosage} of ${m.name}.',
        time: TimeOfDay.fromDateTime(m.toBeTakenAt!),
      );
    }
  }

  /// Cancels every section's reminder; UNKNOWN rows came from an older list sync.
  Future<void> _cancelAlarms(String id) async {
    for (final section in [
      ...MedicationSection.values.map((s) => s.key),
      'UNKNOWN'
    ]) {
      await notificationService.cancelReminder(medicationReminderId(id, section));
    }
  }
}
