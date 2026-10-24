import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import '../datasources/medication_remote_datasource.dart';
import '../mappers/medication_mapper.dart';
import '../services/medication_reminders.dart';

part 'medication_adherence.dart';
part 'medication_refresh.dart';

/// Offline-first [MedicationRepository] backed by the local database and the API.
class MedicationRepositoryImpl
    with _MedicationAdherence, _MedicationRefresh
    implements MedicationRepository {
  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
    required this.mutationSyncManager,
    required this.notificationService,
    required this.session,
    required this.l10n,
  });

  @override
  final MedicationRemoteDataSource remoteDataSource;
  @override
  final ConnectivityService connectivityService;
  @override
  final AppDatabase db;
  final MutationSyncManager mutationSyncManager;
  final NotificationService notificationService;
  @override
  final SessionEpoch session;

  /// The app's current translations, read each time reminders are scheduled.
  final AppLocalizations Function() l10n;

  @override
  late final _reminders = MedicationReminders(notificationService, l10n);

  static const _type = 'medication';

  /// Ids made on this phone are UUIDs; server ids have no dashes.
  static bool _isLocalId(String id) => id.contains('-');

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
  AsyncResult<void> confirmDose(
          String medicationId, MedicationSection section) =>
      guard(() async {
        final now = clock.now();
        final day = AppDateFormats.yyyyMMdd.format(now);
        final row = (await _meds.getMedicationById(medicationId))
            .where((m) => m.section == section.key)
            .firstOrNull;
        // The local "taken" state and its queued sync are saved together or not at all.
        await db.transaction(() async {
          if (row != null) {
            await _meds.updateMedication(
                row.copyWith(taken: true, takenOn: Value(now)));
          }
          await _queue(medicationId, 'confirmMedication',
              {'section': section.key, 'date': day});
          await db.adherenceDao.markMedicationLogAsTakenOffline(
              const Uuid().v4(), medicationId, now);
          await db.adherenceDao.markGlobalDayAsTakenOffline(day);
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
          throw _isLocalId(id)
              ? const NotFoundFailure()
              : const NetworkFailure();
        }
        try {
          final epoch = session.current;
          final remote = await remoteDataSource.getMedicationById(id);
          session.ensure(epoch);
          for (final row in rows) {
            await _meds.updateMedication(row.copyWith(
              morningJson:
                  Value(MedicationMapper.encodeSchedule(remote.morning)),
              afternoonJson:
                  Value(MedicationMapper.encodeSchedule(remote.afternoon)),
              eveningJson:
                  Value(MedicationMapper.encodeSchedule(remote.evening)),
            ));
          }
          return remote;
        } catch (_) {
          if (local != null) return local;
          rethrow;
        }
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
        await _reminders.schedule(rows);
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
          await _reminders.cancel(id);
          await _reminders.schedule(rows);
        }
        mutationSyncManager.triggerSync();
      });

  @override
  AsyncResult<void> deleteMedication(String id) => guard(() async {
        await db.transaction(() async {
          await _meds.deleteMedication(id);
          await _queue(id, 'deleteMedication', const {});
        });
        await _reminders.cancel(id);
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
  Future<void> syncLocalAlarms() async =>
      _reminders.replaceAll(await _meds.getAllMedications());

  @override
  Future<bool> remindersAreExact() => _reminders.areExact();

  @override
  Future<void> allowExactReminders() async {
    if (await _reminders.allowExact()) await syncLocalAlarms();
  }

  @override
  Future<void> moveReminders(String oldId, String newId) async {
    await _reminders.cancel(oldId);
    await _reminders.cancel(newId);
    await _reminders.schedule(await _meds.getMedicationById(newId));
  }

  Future<void> _queue(String id, String action, Map<String, dynamic> payload) =>
      db.pendingMutationsDao.queueMutation(
          entityId: id, entityType: _type, action: action, payload: payload);
}
