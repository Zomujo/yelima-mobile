import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart' as drift;
import '../../../../core/db/app_database.dart';
import '../datasources/medication_local_datasource.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../core/services/connectivity_service.dart';

import '../../../../core/utils/custom_types.dart';
import '../../../../core/utils/logger.dart';

import '../../domain/entities/medication_adherence.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_history_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_datasource.dart';
import '../mappers/medication_mapper.dart';
import '../models/create_medication_model.dart';
import '../models/update_medication_model.dart';
import '../models/medication_detail_model.dart';
import '../models/seeded_medication_list_response_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final MedicationLocalDataSource localDataSource;
  final MutationSyncManager mutationSyncManager;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.localDataSource,
    required this.mutationSyncManager,
  });

  /// Retrieves adherence rates directly from the local cache.
  @override
  AsyncResponse<MedicationAdherence> getCachedAdherence(
      {required bool showWeekdays}) async {
    final typeId = showWeekdays ? 'global_weekly' : 'global_monthly';

    final rateObj = await localDataSource.getGlobalAdherenceRate(typeId);
    if (rateObj == null) {
      return right(const MedicationAdherence(rate: 0, days: []));
    }

    final days = await localDataSource.getGlobalAdherenceDays();
    final filteredDays = days.where((d) => d.type == typeId).toList();

    return right(MedicationAdherence(
      rate: rateObj.rate,
      days: filteredDays
          .map((d) => AdherenceDay(
                taken: d.taken ?? false,
                takenAt: DateTime.parse(d.dateTakenStr).toLocal(),
                id: d.label, // use id parameter for label mapping
              ))
          .toList(),
    ));
  }

  /// Subscribes to real-time updates for medication counts.
  @override
  Stream<MedicationCount> watchMedicationCounts() => const Stream.empty();

  /// Subscribes to local medication updates for a specific section and triggers a silent background sync.
  @override
  Stream<List<MedicationEntity>> watchMedicationsBySection(String section) {
    _fetchAndCacheMedicationsBySection(section);
    return localDataSource.watchMedicationsBySection(section).map(
          (list) => list.map(MedicationMapper.toEntity).toList(),
        );
  }

  /// Subscribes to real-time updates for all local medications.
  @override
  Stream<List<MedicationEntity>> watchAllMedications() {
    return localDataSource.watchAllMedications().map(
          (list) => list.map(MedicationMapper.toEntity).toList(),
        );
  }

  /// Silently fetches and synchronizes medications for a section from the remote source.
  Future<void> _fetchAndCacheMedicationsBySection(String section) async {
    if (await connectivityService.isConnected) {
      try {
        final remoteMeds =
            await remoteDataSource.getMedicationsBySection(section);

        final existingMeds = await localDataSource.getAllMedications();
        final existingMap = {
          for (var m in existingMeds) '${m.id}_${m.section}': m
        };

        final localMeds = remoteMeds.map((m) {
          final existing = existingMap['${m.id}_$section'];
          return Medication(
            id: m.id,
            name: m.name,
            dosage: m.dosage,
            purpose: existing?.purpose ?? m.purpose,
            toBeTakenAt: m.toBeTakenAt,
            taken: m.taken,
            section: section,
            notes: existing?.notes,
            morningJson: existing?.morningJson,
            afternoonJson: existing?.afternoonJson,
            eveningJson: existing?.eveningJson,
          );
        }).toList();

        final pendingMutations = await localDataSource.getAllPendingMutations();
        final activeMutationEntityIds = pendingMutations
            .where((m) => m.entityType == 'medication')
            .map((m) => m.entityId)
            .toSet();

        final localMedsToInsert = localMeds
            .where((m) => !activeMutationEntityIds.contains(m.id))
            .toList();

        final remoteIds = remoteMeds.map((m) => m.id).toSet();
        final localMedsToDelete = existingMeds
            .where((m) =>
                m.section == section &&
                !remoteIds.contains(m.id) &&
                !activeMutationEntityIds.contains(m.id))
            .map((m) => m.id)
            .toList();

        for (var id in localMedsToDelete) {
          await localDataSource.deleteMedication(id);
        }

        await localDataSource.insertMedications(localMedsToInsert);
      } catch (_) {}
    }
  }

  /// Fetches adherence data from the remote source, falling back to cache on failure.
  @override
  AsyncResponse<MedicationAdherence> getAdherence(
      {required bool showWeekdays}) async {
    final hasPending =
        await localDataSource.hasPendingMutationsForType('medication');

    if (await connectivityService.isConnected && !hasPending) {
      try {
        final result =
            await remoteDataSource.getAdherence(showWeekdays: showWeekdays);

        final typeId = showWeekdays ? 'global_weekly' : 'global_monthly';

        final driftDays = result.days.map((d) {
          return AdherenceGlobalDay(
            dateTakenStr: d.takenAt.toIso8601String(),
            taken: d.taken,
            label: d.id ?? '',
            type: typeId,
          );
        }).toList();

        await localDataSource.saveGlobalAdherence(
            typeId, result.rate.toDouble(), driftDays);

        return right(result);
      } catch (e) {
        final cached = await getCachedAdherence(showWeekdays: showWeekdays);
        return cached.fold((l) => left('Server error and no cache available'),
            (r) => right(r));
      }
    } else {
      return getCachedAdherence(showWeekdays: showWeekdays);
    }
  }

  /// Subscribes to real-time updates for medication adherence.
  @override
  Stream<MedicationAdherence> watchAdherence() => const Stream.empty();

  /// Calculates medication counts based on current local records.
  @override
  AsyncResponse<MedicationCount> getMedicationCounts() async {
    final meds = await localDataSource.getAllMedications();

    final m = meds.where((m) => m.section == 'MORNING').length;
    final a = meds.where((m) => m.section == 'AFTERNOON').length;
    final e = meds.where((m) => m.section == 'EVENING').length;

    return right(MedicationCount(morning: m, afternoon: a, evening: e));
  }

  /// Retrieves a static list of local medications for a section and triggers a background sync.
  @override
  AsyncResponse<List<MedicationEntity>> getMedicationsBySection(
      String section) async {
    final meds = await localDataSource.watchMedicationsBySection(section).first;
    _fetchAndCacheMedicationsBySection(section);
    return right(meds.map(MedicationMapper.toEntity).toList());
  }

  /// Marks a medication as taken, updating local records optimistically and enqueueing a sync mutation.
  @override
  AsyncResponse<void> confirmMedication(String medicationId, String section,
      {String? date}) async {
    final effectiveDate =
        date ?? DateTime.now().toIso8601String().split('T')[0];

    final meds = await localDataSource.getAllMedications();
    final target = meds
        .where((m) => m.id == medicationId && m.section == section)
        .firstOrNull;
    if (target != null) {
      await localDataSource.updateMedication(target.copyWith(taken: true));
    }

    final payload = {
      'section': section,
      'date': effectiveDate,
    };

    final pending = PendingMutationsCompanion.insert(
      id: const Uuid().v4(),
      entityType: 'medication',
      entityId: medicationId,
      action: 'confirmMedication',
      payloadJson: jsonEncode(payload),
      createdAt: DateTime.now(),
    );

    await localDataSource.addPendingMutation(pending);

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    await localDataSource.markMedicationLogAsTakenOffline(
      const Uuid().v4(),
      medicationId,
      DateTime.now(),
    );
    await localDataSource.markGlobalDayAsTakenOffline(todayStr);

    mutationSyncManager.triggerSync();

    return right(null);
  }

  /// Retrieves all unique medications and triggers a background pagination sync.
  @override
  AsyncResponse<MedicationListResponse> getAllMedications(
      {int page = 1, int pageSize = 10, bool forceRefresh = false}) async {
    final meds = await localDataSource.watchAllMedications().first;

    if (await connectivityService.isConnected) {
      _syncAllMedicationsBackground(page, pageSize);
    }

    final Map<String, MedicationEntity> uniqueMeds = {};
    for (var med in meds) {
      if (!uniqueMeds.containsKey(med.id)) {
        uniqueMeds[med.id] = MedicationMapper.toEntity(med);
      }
    }

    return right(MedicationListResponse(
      rows: uniqueMeds.values.toList(),
      total: uniqueMeds.length,
      pageSize: pageSize,
      page: page,
      totalPages: 1,
    ));
  }

  /// Silently synchronizes paginated remote medications into the local database.
  Future<void> _syncAllMedicationsBackground(int page, int pageSize) async {
    try {
      final remoteRes = await remoteDataSource.getAllMedications(
          page: page, pageSize: pageSize);
      final pendingMutations = await localDataSource.getAllPendingMutations();
      final activeMutationEntityIds = pendingMutations
          .where((m) => m.entityType == 'medication')
          .map((m) => m.entityId)
          .toSet();

      final localMedsToInsert = <Medication>[];
      for (final m in remoteRes.rows) {
        if (activeMutationEntityIds.contains(m.id)) continue;
        final existing = await localDataSource.getMedicationById(m.id);
        final existingBase = existing.isNotEmpty ? existing.first : null;
        localMedsToInsert.add(Medication(
          id: m.id,
          name: m.name,
          dosage: m.dosage,
          purpose: m.purpose,
          toBeTakenAt: m.toBeTakenAt,
          taken: m.taken,
          section: 'UNKNOWN',
          morningJson: existingBase?.morningJson,
          afternoonJson: existingBase?.afternoonJson,
          eveningJson: existingBase?.eveningJson,
          notes: existingBase?.notes,
        ));
      }
      await localDataSource.insertMedications(localMedsToInsert);
    } catch (e, stack) {
      AppLogger.e('Failed to sync medications in background', e, stack);
    }
  }

  /// Fetches medication history logs from remote, falling back to local records.
  @override
  AsyncResponse<MedicationHistoryEntity> getMedicationHistory(
      String medicationId,
      {required String date}) async {
    final hasPending =
        await localDataSource.hasPendingMutationsForEntity(medicationId);

    if (await connectivityService.isConnected && !hasPending) {
      try {
        final result = await remoteDataSource.getMedicationHistory(medicationId,
            date: date);

        final driftLogs = result.logs
            .map((l) => MedicationLog(
                  id: l.id,
                  medicationId: medicationId,
                  takenAt: l.takenAt,
                  taken: l.taken,
                ))
            .toList();

        await localDataSource.saveMedicationLogs(driftLogs);

        return right(result);
      } catch (e, stack) {
        AppLogger.e('Failed to get remote medication history', e, stack);
      }
    }

    final localLogs = await localDataSource.getLogsForMedication(medicationId);

    final medList = await localDataSource.getMedicationById(medicationId);
    final med = medList.firstOrNull;
    final medName = med?.name ?? 'Unknown Medication';

    final total = localLogs.length;
    final taken = localLogs.where((l) => l.taken).length;
    final rate = total > 0 ? ((taken / total) * 100).round() : 0;

    return right(MedicationHistoryEntity(
      medicationName: medName,
      adherenceRate: rate,
      logs: localLogs
          .map((l) => MedicationLogEntity(
                id: l.id,
                taken: l.taken,
                takenAt: l.takenAt,
              ))
          .toList(),
    ));
  }

  /// Persists a new medication locally and enqueues a creation mutation.
  @override
  AsyncResponse<String> createMedication(CreateMedicationModel data) async {
    final localId = const Uuid().v4();

    final medsToInsert = MedicationMapper.fromCreateModel(data, localId);

    await localDataSource.insertMedications(medsToInsert);

    final pending = PendingMutationsCompanion.insert(
      id: const Uuid().v4(),
      entityType: 'medication',
      entityId: localId,
      action: 'createMedication',
      payloadJson: jsonEncode(data.toJson()),
      createdAt: DateTime.now(),
    );

    await localDataSource.addPendingMutation(pending);
    mutationSyncManager.triggerSync();

    return right(localId);
  }

  /// Fetches detailed medication info from the remote source and synchronizes local schedule JSON.
  @override
  AsyncResponse<MedicationDetailModel> getMedicationById(String id) async {
    final localMeds = await localDataSource.getMedicationById(id);
    MedicationDetailModel? localDetail;

    if (localMeds.isNotEmpty) {
      localDetail = MedicationMapper.toDetailModel(localMeds.first);
    }

    if (await connectivityService.isConnected && !id.contains('-')) {
      try {
        final result = await remoteDataSource.getMedicationById(id);

        if (localMeds.isNotEmpty) {
          final mJson = MedicationMapper.encodeSchedule(result.morning);
          final aJson = MedicationMapper.encodeSchedule(result.afternoon);
          final eJson = MedicationMapper.encodeSchedule(result.evening);

          for (final med in localMeds) {
            await localDataSource.updateMedication(med.copyWith(
              morningJson: drift.Value(mJson),
              afternoonJson: drift.Value(aJson),
              eveningJson: drift.Value(eJson),
            ));
          }
        }
        return right(result);
      } on ApiException catch (e) {
        if (localDetail != null) return right(localDetail);
        return left(e.message ?? 'Server error');
      } catch (e, stack) {
        AppLogger.e('Failed to get remote medication detail', e, stack);
        if (localDetail != null) return right(localDetail);
        return left('Unexpected error');
      }
    }

    if (localDetail != null) {
      return right(localDetail);
    }

    if (id.contains('-')) {
      return left('Medication is currently syncing to the server.');
    }
    return left('No internet');
  }

  /// Updates existing local medications and enqueues an update mutation.
  @override
  AsyncResponse<String> updateMedication(
      String id, UpdateMedicationModel data) async {
    final meds = await localDataSource.getAllMedications();
    final targetMeds = meds.where((m) => m.id == id).toList();

    if (targetMeds.isNotEmpty) {
      await localDataSource.deleteMedication(id);
      final newMeds = MedicationMapper.fromUpdateModel(data, id, targetMeds);

      await localDataSource.insertMedications(newMeds);
    }

    final pending = PendingMutationsCompanion.insert(
      id: const Uuid().v4(),
      entityType: 'medication',
      entityId: id,
      action: 'updateMedication',
      payloadJson: jsonEncode(data.toJson()),
      createdAt: DateTime.now(),
    );

    await localDataSource.addPendingMutation(pending);
    mutationSyncManager.triggerSync();

    return right(id);
  }

  /// Retrieves preloaded seed medications exclusively from the local cache.
  @override
  AsyncResponse<SeededMedicationListResponseModel> getPreloadedMedications(
      {int page = 1, int limit = 10, String? search}) async {
    final cached =
        await localDataSource.searchPreloadedMedications(search ?? '');

    return right(SeededMedicationListResponseModel(
      rows: cached.map(MedicationMapper.toSeededMedication).toList(),
      total: cached.length,
      page: page,
      pageSize: limit,
    ));
  }
}
