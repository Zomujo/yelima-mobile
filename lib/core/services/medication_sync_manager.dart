import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:drift/drift.dart' as drift;

import '../db/app_database.dart';
import '../../features/medications/data/datasources/medication_remote_datasource.dart';
import '../../features/medications/domain/entities/medication_entity.dart';
import '../../features/medications/data/models/medication_adherence_model.dart';
import 'session_lifecycle_service.dart';

/// Pulls the authoritative medication list from the server and merges it
/// into the local cache. Pushing local mutations (create/update/confirm) is
/// a separate responsibility owned entirely by [MutationSyncManager] via the
/// PendingMutations outbox - this manager only ever reads from the server.
class MedicationSyncManager implements SessionLifecycleHandler {
  final AppDatabase db;
  final MedicationRemoteDataSource remoteDataSource;

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  MedicationSyncManager(this.db, this.remoteDataSource);

  @override
  String get serviceName => 'MedicationSyncManager';

  @override
  Future<void> onSessionStarted(String userId) async {
    startListening();
    // Do an initial sync check
    triggerSync();
  }

  @override
  Future<void> onSessionEnded() async {
    stopListening();
  }

  void startListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      if (status == InternetStatus.connected) {
        triggerSync();
      }
    });
  }

  void stopListening() {
    _connectivitySubscription?.cancel();
  }

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) return;

    _isSyncing = true;
    try {
      debugPrint('MedicationSyncManager: Starting pull...');
      await _pullAndMerge();
      debugPrint('MedicationSyncManager: Pull complete.');
    } catch (e) {
      debugPrint('MedicationSyncManager: Pull failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pullAndMerge() async {
    try {
      // 1. Fetch raw medication definitions
      final response =
          await remoteDataSource.getAllMedications(page: 1, pageSize: 100);
      final remoteMeds = response.rows;

      // 2. Fetch daily adherence lists concurrently
      List<MedicationEntity> morningMeds = [];
      List<MedicationEntity> afternoonMeds = [];
      List<MedicationEntity> eveningMeds = [];
      MedicationAdherenceModel? adherenceResult;

      try {
        final results = await Future.wait([
          remoteDataSource.getMedicationsBySection('MORNING'),
          remoteDataSource.getMedicationsBySection('AFTERNOON'),
          remoteDataSource.getMedicationsBySection('EVENING'),
        ]);
        morningMeds = results[0];
        afternoonMeds = results[1];
        eveningMeds = results[2];
      } catch (e) {
        debugPrint('Failed to fetch sections: $e');
      }

      try {
        adherenceResult =
            await remoteDataSource.getAdherence(showWeekdays: true);
      } catch (e) {
        debugPrint('Failed to fetch adherence: $e');
      }

      // Build taken map
      final takenMap = <String, bool>{};
      for (var sectionMeds in [morningMeds, afternoonMeds, eveningMeds]) {
        for (var med in sectionMeds) {
          if (med.taken) {
            takenMap[med.id] = true;
          }
        }
      }

      await db.transaction(() async {
        final localMeds = await db.medicationsDao.getAllMedications();

        // The PendingMutations outbox is the single source of truth for
        // "is there local state this pull must not clobber" - a syncStatus
        // column check isn't enough, since e.g. an offline confirm never
        // touches syncStatus at all but still must not be overwritten here.
        final pendingAll =
            await db.pendingMutationsDao.getAllPendingMutations();
        final pendingMedIds = pendingAll
            .where((p) => p.entityType == 'medication')
            .map((p) => p.entityId)
            .toSet();

        for (var remote in remoteMeds) {
          final local = localMeds.where((m) => m.id == remote.id).firstOrNull;

          // If local has an unresolved mutation (create/update/confirm),
          // don't overwrite it yet - the outbox hasn't pushed it out.
          if (local != null && pendingMedIds.contains(local.id)) {
            continue;
          }

          // Neither the list nor section endpoints carry the morning/
          // afternoon/evening schedule (confirmed: both only return a
          // toBeTakenAt-style summary) - leave those columns untouched here
          // (Value.absent()) and let _backfillMissingSchedules populate them
          // from the single-item detail endpoint, the only one that has it.
          final companion = MedicationsCompanion(
            id: drift.Value(remote.id),
            name: drift.Value(remote.name),
            dosage: drift.Value(remote.dosage),
            purpose: drift.Value(remote.purpose),
            syncStatus: const drift.Value('synced'),
            lastModifiedAt: drift.Value(DateTime.now()),
            taken: drift.Value(takenMap[remote.id] ?? false),
          );

          await db.medicationsDao.insertOrUpdateMedication(companion);
        }

        final remoteIds = remoteMeds.map((m) => m.id).toSet();
        for (var local in localMeds) {
          if (!pendingMedIds.contains(local.id) &&
              !remoteIds.contains(local.id)) {
            await db.medicationsDao.deleteMedication(local.id);
          }
        }

        // Hydrate Adherence Cache
        if (adherenceResult != null) {
          final basicModel = VitalHistoriesCompanion(
            id: const drift.Value('adherence_cache_key'),
            vitalType: const drift.Value('ADHERENCE_CACHE'),
            vitalName: const drift.Value('Medication Adherence'),
            value: drift.Value(adherenceResult.rate.toString()),
            unit: const drift.Value('%'),
            severity: const drift.Value('normal'),
            recordedAt: drift.Value(DateTime.now()),
          );

          final daysJson = adherenceResult.days
              .map((d) => {
                    'id': d.id,
                    'taken': d.taken,
                    'takenAt': d.takenAt.toIso8601String(),
                  })
              .toList();

          final fullModel = VitalHistoriesCompanion(
            id: const drift.Value('adherence_full_cache_key'),
            vitalType: const drift.Value('ADHERENCE_FULL_CACHE'),
            vitalName: const drift.Value('Medication Adherence Full'),
            value: drift.Value(
                jsonEncode({'rate': adherenceResult.rate, 'days': daysJson})),
            unit: const drift.Value('json'),
            severity: const drift.Value('normal'),
            recordedAt: drift.Value(DateTime.now()),
          );

          await db.vitalsDao.insertVitals([basicModel, fullModel]);
        }
      });

      await _backfillMissingSchedules(remoteMeds.map((m) => m.id).toSet());
    } catch (e) {
      debugPrint('Pull failed: $e');
      rethrow;
    }
  }

  Future<void> _backfillMissingSchedules(Set<String> remoteIds) async {
    try {
      final localMeds = await db.medicationsDao.getAllMedications();
      final missingIds = localMeds
          .where((m) =>
              remoteIds.contains(m.id) &&
              m.morningSchedule == null &&
              m.afternoonSchedule == null &&
              m.eveningSchedule == null)
          .map((m) => m.id)
          .toList();

      if (missingIds.isEmpty) {
        debugPrint('MedicationSyncManager: schedule backfill - nothing missing.');
        return;
      }
      debugPrint(
          'MedicationSyncManager: schedule backfill - fetching detail for ${missingIds.length} medication(s): $missingIds');

      final details = await Future.wait(missingIds.map((id) async {
        try {
          final detail = await remoteDataSource.getMedicationById(id);
          debugPrint(
              'MedicationSyncManager: detail($id) => morning=${detail.morning} afternoon=${detail.afternoon} evening=${detail.evening}');
          return MapEntry(id, detail);
        } catch (e) {
          debugPrint('MedicationSyncManager: detail fetch failed for $id: $e');
          return null;
        }
      }));

      for (final entry in details) {
        if (entry == null) continue;
        final detail = entry.value;
        if (detail.morning == null &&
            detail.afternoon == null &&
            detail.evening == null) {
          continue; // Genuinely has no schedule.
        }

        // This row is already known to exist locally (that's the
        // precondition for landing in missingIds) - a plain partial UPDATE,
        // not insertOrUpdateMedication, which would demand name/dosage/
        // purpose be present too since it validates as a possible INSERT.
        await db.medicationsDao.updateMedicationFields(
          entry.key,
          MedicationsCompanion(
            morningSchedule: detail.morning != null
                ? drift.Value(jsonEncode(detail.morning!.toJson()))
                : const drift.Value.absent(),
            afternoonSchedule: detail.afternoon != null
                ? drift.Value(jsonEncode(detail.afternoon!.toJson()))
                : const drift.Value.absent(),
            eveningSchedule: detail.evening != null
                ? drift.Value(jsonEncode(detail.evening!.toJson()))
                : const drift.Value.absent(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Schedule backfill failed: $e');
    }
  }
}
