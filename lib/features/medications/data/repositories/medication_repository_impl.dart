import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart' as drift;
import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/medications_dao.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../../../core/utils/custom_types.dart';

import '../../domain/entities/medication_adherence.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_history_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_datasource.dart';
import '../models/create_medication_model.dart';
import '../models/update_medication_model.dart';
import '../models/medication_detail_model.dart';
import '../models/seeded_medication_list_response_model.dart';
import '../models/seeded_medication_model.dart';
import '../models/dosing_schedule_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final MedicationsDao medicationsDao;
  final AppDatabase db;
  final MutationSyncManager mutationSyncManager;
  final SharedPrefsService sharedPrefsService;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.medicationsDao,
    required this.db,
    required this.mutationSyncManager,
    required this.sharedPrefsService,
  });

  MedicationEntity _mapToEntity(Medication med) {
    return MedicationEntity(
      id: med.id,
      name: med.name,
      dosage: med.dosage,
      purpose: med.purpose ?? '',
      toBeTakenAt: med.toBeTakenAt ?? DateTime.now(),
      taken: med.taken,
    );
  }

  @override
  AsyncResponse<MedicationAdherence> getCachedAdherence(
      {required bool showWeekdays}) async {
    final typeId = showWeekdays ? 'global_weekly' : 'global_monthly';

    final rateObj = await db.adherenceDao.getGlobalAdherenceRate(typeId);
    if (rateObj == null) {
      return right(const MedicationAdherence(rate: 0, days: []));
    }

    final days = await db.adherenceDao.getGlobalAdherenceDays();
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

  @override
  Stream<MedicationCount> watchMedicationCounts() => const Stream.empty();

  @override
  Stream<List<MedicationEntity>> watchMedicationsBySection(String section) {
    // Optionally trigger a silent network fetch here
    _fetchAndCacheMedicationsBySection(section);
    return medicationsDao.watchMedicationsBySection(section).map(
          (list) => list.map(_mapToEntity).toList(),
        );
  }

  @override
  Stream<List<MedicationEntity>> watchAllMedications() {
    return medicationsDao.watchAllMedications().map(
          (list) => list.map(_mapToEntity).toList(),
        );
  }

  Future<void> _fetchAndCacheMedicationsBySection(String section) async {
    if (await connectivityService.isConnected) {
      try {
        final remoteMeds =
            await remoteDataSource.getMedicationsBySection(section);

        final existingMeds = await db.medicationsDao.getAllMedications();
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

        final pendingMutations =
            await db.pendingMutationsDao.getAllPendingMutations();
        final activeMutationEntityIds = pendingMutations
            .where((m) => m.entityType == 'medication')
            .map((m) => m.entityId)
            .toSet();

        final localMedsToInsert = localMeds
            .where((m) => !activeMutationEntityIds.contains(m.id))
            .toList();

        // Delete meds that are no longer on the server for this section
        final remoteIds = remoteMeds.map((m) => m.id).toSet();
        final localMedsToDelete = existingMeds
            .where((m) =>
                m.section == section &&
                !remoteIds.contains(m.id) &&
                !activeMutationEntityIds.contains(m.id))
            .map((m) => m.id)
            .toList();

        for (var id in localMedsToDelete) {
          await db.medicationsDao.deleteMedication(id);
        }

        await medicationsDao.insertMedications(localMedsToInsert);
      } catch (_) {
        // Silent fail for background sync
      }
    }
  }

  @override
  AsyncResponse<MedicationAdherence> getAdherence(
      {required bool showWeekdays}) async {
    final hasPending = await (db.select(db.pendingMutations)
          ..where((t) => t.entityType.equals('medication')))
        .get()
        .then((l) => l.isNotEmpty);

    if (await connectivityService.isConnected && !hasPending) {
      try {
        final result =
            await remoteDataSource.getAdherence(showWeekdays: showWeekdays);

        final typeId = showWeekdays ? 'global_weekly' : 'global_monthly';

        // Save to SQLite
        final driftDays = result.days.map((d) {
          return AdherenceGlobalDay(
            dateTakenStr: d.takenAt.toIso8601String(),
            taken: d.taken,
            label: d.id ?? '',
            type: typeId,
          );
        }).toList();

        await db.adherenceDao
            .saveGlobalAdherence(typeId, result.rate, driftDays);

        return right(result);
      } catch (e) {
        // Fallback to SQLite cache on server error
        final cached = await getCachedAdherence(showWeekdays: showWeekdays);
        return cached.fold((l) => left('Server error and no cache available'),
            (r) => right(r));
      }
    } else {
      return getCachedAdherence(showWeekdays: showWeekdays);
    }
  }

  @override
  Stream<MedicationAdherence> watchAdherence() => const Stream.empty();

  @override
  AsyncResponse<MedicationCount> getMedicationCounts() async {
    // Dynamically calculate counts from the local Medications table to
    // seamlessly support optimistic offline UI updates.
    final meds = await medicationsDao.getAllMedications();

    int m = 0, a = 0, e = 0;
    for (var med in meds) {
      if (med.section == 'MORNING') {
        m++;
      } else if (med.section == 'AFTERNOON') {
        a++;
      } else if (med.section == 'EVENING') {
        e++;
      }
    }

    return right(MedicationCount(morning: m, afternoon: a, evening: e));
  }

  @override
  AsyncResponse<List<MedicationEntity>> getMedicationsBySection(
      String section) async {
    // Return from local DB instead of remote
    final meds = await medicationsDao.watchMedicationsBySection(section).first;
    _fetchAndCacheMedicationsBySection(section);
    return right(meds.map(_mapToEntity).toList());
  }

  @override
  AsyncResponse<void> confirmMedication(String medicationId, String section,
      {String? date}) async {
    final effectiveDate =
        date ?? DateTime.now().toIso8601String().split('T')[0];

    // Optimistically update local DB
    final meds = await medicationsDao.getAllMedications();
    final target = meds
        .where((m) => m.id == medicationId && m.section == section)
        .firstOrNull;
    if (target != null) {
      await medicationsDao.updateMedication(target.copyWith(taken: true));
    }

    // Enqueue Mutation
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

    await db.pendingMutationsDao.addPendingMutation(pending);

    // Optimistically update Adherence metrics so dashboards refresh instantly offline
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    await db.adherenceDao.markMedicationLogAsTakenOffline(
      const Uuid().v4(), // generate temporary log id
      medicationId,
      DateTime.now(),
    );
    await db.adherenceDao.markGlobalDayAsTakenOffline(todayStr);

    mutationSyncManager.triggerSync();

    return right(null);
  }

  @override
  AsyncResponse<MedicationListResponse> getAllMedications(
      {int page = 1, int pageSize = 10, bool forceRefresh = false}) async {
    final meds = await medicationsDao.watchAllMedications().first;

    // Trigger background sync if online
    if (await connectivityService.isConnected) {
      remoteDataSource
          .getAllMedications(page: page, pageSize: pageSize)
          .then((remoteRes) async {
        final pendingMutations =
            await db.pendingMutationsDao.getAllPendingMutations();
        final activeMutationEntityIds = pendingMutations
            .where((m) => m.entityType == 'medication')
            .map((m) => m.entityId)
            .toSet();

        final localMedsToInsert = <Medication>[];
        for (final m in remoteRes.rows) {
          if (activeMutationEntityIds.contains(m.id)) continue;
          final existing = await medicationsDao.getMedicationById(m.id);
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
        await medicationsDao.insertMedications(localMedsToInsert);
      }).catchError((_) {});
    }

    final Map<String, MedicationEntity> uniqueMeds = {};
    for (var med in meds) {
      if (!uniqueMeds.containsKey(med.id)) {
        uniqueMeds[med.id] = _mapToEntity(med);
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

  @override
  AsyncResponse<MedicationHistoryEntity> getMedicationHistory(
      String medicationId,
      {required String date}) async {
    // If there are pending actions for this medication, our local cache is ahead of the server.
    // Force the offline fallback so we don't overwrite the optimistic data.
    final hasPending = await (db.select(db.pendingMutations)
          ..where((t) => t.entityId.equals(medicationId)))
        .get()
        .then((l) => l.isNotEmpty);

    if (await connectivityService.isConnected && !hasPending) {
      try {
        final result = await remoteDataSource.getMedicationHistory(medicationId,
            date: date);

        // Cache logs locally
        final driftLogs = result.logs
            .map((l) => MedicationLog(
                  id: l.id,
                  medicationId: medicationId,
                  takenAt: l.takenAt,
                  taken: l.taken,
                ))
            .toList();

        await db.adherenceDao.saveMedicationLogs(driftLogs);

        return right(result);
      } catch (e) {
        // Fallback for local UUIDs which haven't synced yet or offline
      }
    }

    // Fallback for offline: Load from AdherenceDao
    final localLogs = await db.adherenceDao.getLogsForMedication(medicationId);

    // We try to get the medication name from local DB
    final med = await (db.select(db.medications)
          ..where((tbl) => tbl.id.equals(medicationId))
          ..limit(1))
        .getSingleOrNull();
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

  DateTime _deriveTime(int hour, int minute, String period) {
    int h24 = hour;
    if (period.toUpperCase() == 'PM' && h24 < 12) {
      h24 += 12;
    } else if (period.toUpperCase() == 'AM' && h24 == 12) {
      h24 = 0;
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h24, minute);
  }

  @override
  AsyncResponse<String> createMedication(CreateMedicationModel data) async {
    final localId = const Uuid().v4();

    final morningJson =
        data.morning != null ? jsonEncode(data.morning!.toJson()) : null;
    final afternoonJson =
        data.afternoon != null ? jsonEncode(data.afternoon!.toJson()) : null;
    final eveningJson =
        data.evening != null ? jsonEncode(data.evening!.toJson()) : null;

    final medsToInsert = <Medication>[];
    if (data.morning != null) {
      medsToInsert.add(Medication(
          id: localId,
          name: data.name,
          dosage: data.dosage,
          notes: data.notes,
          toBeTakenAt: _deriveTime(data.morning!.time.hour,
              data.morning!.time.minutes, data.morning!.time.timeDesignators),
          taken: false,
          section: 'MORNING',
          morningJson: morningJson,
          afternoonJson: afternoonJson,
          eveningJson: eveningJson));
    }
    if (data.afternoon != null) {
      medsToInsert.add(Medication(
          id: localId,
          name: data.name,
          dosage: data.dosage,
          notes: data.notes,
          toBeTakenAt: _deriveTime(
              data.afternoon!.time.hour,
              data.afternoon!.time.minutes,
              data.afternoon!.time.timeDesignators),
          taken: false,
          section: 'AFTERNOON',
          morningJson: morningJson,
          afternoonJson: afternoonJson,
          eveningJson: eveningJson));
    }
    if (data.evening != null) {
      medsToInsert.add(Medication(
          id: localId,
          name: data.name,
          dosage: data.dosage,
          notes: data.notes,
          toBeTakenAt: _deriveTime(data.evening!.time.hour,
              data.evening!.time.minutes, data.evening!.time.timeDesignators),
          taken: false,
          section: 'EVENING',
          morningJson: morningJson,
          afternoonJson: afternoonJson,
          eveningJson: eveningJson));
    }

    if (medsToInsert.isEmpty) {
      medsToInsert.add(Medication(
          id: localId,
          name: data.name,
          dosage: data.dosage,
          notes: data.notes,
          toBeTakenAt: DateTime.now(),
          taken: false,
          section: 'MORNING',
          morningJson: morningJson,
          afternoonJson: afternoonJson,
          eveningJson: eveningJson));
    }

    await medicationsDao.insertMedications(medsToInsert);

    final pending = PendingMutationsCompanion.insert(
      id: const Uuid().v4(),
      entityType: 'medication',
      entityId: localId,
      action: 'createMedication',
      payloadJson: jsonEncode(data.toJson()),
      createdAt: DateTime.now(),
    );

    await db.pendingMutationsDao.addPendingMutation(pending);
    mutationSyncManager.triggerSync();

    return right(localId);
  }

  @override
  AsyncResponse<MedicationDetailModel> getMedicationById(String id) async {
    final localMeds = await medicationsDao.getMedicationById(id);
    if (localMeds.isNotEmpty) {
      final base = localMeds.first;
      DosingScheduleModel? mModel;
      DosingScheduleModel? aModel;
      DosingScheduleModel? eModel;

      try {
        if (base.morningJson != null) {
          mModel = DosingScheduleModel.fromJson(jsonDecode(base.morningJson!));
        }
        if (base.afternoonJson != null) {
          aModel =
              DosingScheduleModel.fromJson(jsonDecode(base.afternoonJson!));
        }
        if (base.eveningJson != null) {
          eModel = DosingScheduleModel.fromJson(jsonDecode(base.eveningJson!));
        }
      } catch (_) {}

      final localDetail = MedicationDetailModel(
        id: base.id,
        name: base.name,
        dosage: base.dosage,
        notes: base.notes,
        morning: mModel,
        afternoon: aModel,
        evening: eModel,
        createdAt: base.toBeTakenAt ?? DateTime.now(),
        updatedAt: base.toBeTakenAt ?? DateTime.now(),
      );

      if (await connectivityService.isConnected && !id.contains('-')) {
        try {
          final result = await remoteDataSource.getMedicationById(id);

          final mJson = result.morning != null
              ? jsonEncode(result.morning!.toJson())
              : null;
          final aJson = result.afternoon != null
              ? jsonEncode(result.afternoon!.toJson())
              : null;
          final eJson = result.evening != null
              ? jsonEncode(result.evening!.toJson())
              : null;

          // Update all local rows for this medication with the new JSON schedules
          for (final med in localMeds) {
            await medicationsDao.updateMedication(med.copyWith(
              morningJson: drift.Value(mJson),
              afternoonJson: drift.Value(aJson),
              eveningJson: drift.Value(eJson),
            ));
          }
          return right(result);
        } catch (_) {
          // Silent failure, fallback to local detail below
        }
      }

      return right(localDetail);
    }

    if (await connectivityService.isConnected && !id.contains('-')) {
      try {
        final result = await remoteDataSource.getMedicationById(id);
        return right(result);
      } on ApiException catch (e) {
        return left(e.message ?? 'Server error');
      } catch (e) {
        return left('Unexpected error');
      }
    } else {
      if (id.contains('-')) {
        return left('Medication is currently syncing to the server.');
      }
      return left('No internet');
    }
  }

  @override
  AsyncResponse<String> updateMedication(
      String id, UpdateMedicationModel data) async {
    final meds = await medicationsDao.getAllMedications();
    final targetMeds = meds.where((m) => m.id == id).toList();

    if (targetMeds.isNotEmpty) {
      final base = targetMeds.first;

      final mJson =
          data.morning != null ? jsonEncode(data.morning!.toJson()) : null;
      final aJson =
          data.afternoon != null ? jsonEncode(data.afternoon!.toJson()) : null;
      final eJson =
          data.evening != null ? jsonEncode(data.evening!.toJson()) : null;

      await medicationsDao.deleteMedication(id);

      final newMeds = <Medication>[];
      if (data.morning != null) {
        newMeds.add(Medication(
            id: id,
            name: base.name,
            dosage: data.dosage ?? base.dosage,
            purpose: base.purpose,
            notes: data.notes ?? base.notes,
            toBeTakenAt: _deriveTime(data.morning!.time.hour,
                data.morning!.time.minutes, data.morning!.time.timeDesignators),
            taken: targetMeds
                    .where((m) => m.section == 'MORNING')
                    .firstOrNull
                    ?.taken ??
                false,
            section: 'MORNING',
            morningJson: mJson,
            afternoonJson: aJson,
            eveningJson: eJson));
      }
      if (data.afternoon != null) {
        newMeds.add(Medication(
            id: id,
            name: base.name,
            dosage: data.dosage ?? base.dosage,
            purpose: base.purpose,
            notes: data.notes ?? base.notes,
            toBeTakenAt: _deriveTime(
                data.afternoon!.time.hour,
                data.afternoon!.time.minutes,
                data.afternoon!.time.timeDesignators),
            taken: targetMeds
                    .where((m) => m.section == 'AFTERNOON')
                    .firstOrNull
                    ?.taken ??
                false,
            section: 'AFTERNOON',
            morningJson: mJson,
            afternoonJson: aJson,
            eveningJson: eJson));
      }
      if (data.evening != null) {
        newMeds.add(Medication(
            id: id,
            name: base.name,
            dosage: data.dosage ?? base.dosage,
            purpose: base.purpose,
            notes: data.notes ?? base.notes,
            toBeTakenAt: _deriveTime(data.evening!.time.hour,
                data.evening!.time.minutes, data.evening!.time.timeDesignators),
            taken: targetMeds
                    .where((m) => m.section == 'EVENING')
                    .firstOrNull
                    ?.taken ??
                false,
            section: 'EVENING',
            morningJson: mJson,
            afternoonJson: aJson,
            eveningJson: eJson));
      }

      if (newMeds.isEmpty) {
        newMeds.add(Medication(
            id: id,
            name: base.name,
            dosage: data.dosage ?? base.dosage,
            purpose: base.purpose,
            notes: data.notes ?? base.notes,
            toBeTakenAt: base.toBeTakenAt,
            taken: base.taken,
            section: 'MORNING',
            morningJson: mJson,
            afternoonJson: aJson,
            eveningJson: eJson));
      }

      await medicationsDao.insertMedications(newMeds);
    }

    final pending = PendingMutationsCompanion.insert(
      id: const Uuid().v4(),
      entityType: 'medication',
      entityId: id,
      action: 'updateMedication',
      payloadJson: jsonEncode(data.toJson()),
      createdAt: DateTime.now(),
    );

    await db.pendingMutationsDao.addPendingMutation(pending);
    mutationSyncManager.triggerSync();

    return right(id);
  }

  @override
  AsyncResponse<SeededMedicationListResponseModel> getPreloadedMedications(
      {int page = 1, int limit = 10, String? search}) async {
    // Only query local cache (Background Sync Service handles updates)
    final cached =
        await medicationsDao.searchPreloadedMedications(search ?? '');

    return right(SeededMedicationListResponseModel(
      rows: cached
          .map((c) => SeededMedicationModel(
                id: c.id,
                name: c.name,
                possibleDosages: c.possibleDosagesJson != null
                    ? List<String>.from(jsonDecode(c.possibleDosagesJson!))
                    : [],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ))
          .toList(),
      total: cached.length,
      page: page,
      pageSize: limit,
    ));
  }
}
