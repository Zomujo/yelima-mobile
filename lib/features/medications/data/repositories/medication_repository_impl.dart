import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
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
import '../../../../core/db/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:get_it/get_it.dart';
import '../../../../core/services/mutation_sync_manager.dart';
import '../utils/medication_isolate_parsers.dart';
import '../models/dosing_schedule_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
  });

  // Daily scoped cache key.
  String get _todayKey => DateTime.now().toIso8601String().substring(0, 10);

  @override
  AsyncResponse<MedicationAdherence> getCachedAdherence(
          {required bool showWeekdays}) =>
      _fetchLocalAdherence();

  @override
  Stream<MedicationCount> watchMedicationCounts() {
    return db.medicationsDao.watchAllMedications().map((meds) {
      int m = 0, a = 0, e = 0;
      for (var med in meds) {
        if (med.syncStatus == 'pending_delete') continue;
        if (med.morningSchedule != null) m++;
        if (med.afternoonSchedule != null) a++;
        if (med.eveningSchedule != null) e++;
      }
      return MedicationCount(morning: m, afternoon: a, evening: e);
    });
  }

  @override
  Stream<List<MedicationEntity>> watchMedicationsBySection(String section) {
    return db.medicationsDao.watchAllMedications().map((meds) {
      List<MedicationEntity> results = [];
      final lowerSection = section.toLowerCase();

      for (var med in meds) {
        if (med.syncStatus == 'pending_delete') continue;

        String? scheduleJson;
        if (lowerSection == 'morning') scheduleJson = med.morningSchedule;
        if (lowerSection == 'afternoon') scheduleJson = med.afternoonSchedule;
        if (lowerSection == 'evening') scheduleJson = med.eveningSchedule;

        if (scheduleJson != null) {
          try {
            final map = jsonDecode(scheduleJson);
            final timeModel = map['time'];
            var hour = timeModel['hour'] as int;
            final min = timeModel['minutes'] as int;
            final des = timeModel['timeDesignators'] as String;

            if (des == 'PM' && hour < 12) hour += 12;
            if (des == 'AM' && hour == 12) hour = 0;

            final now = DateTime.now();
            final time = DateTime(now.year, now.month, now.day, hour, min);

            results.add(MedicationEntity(
              id: med.id,
              name: med.name,
              dosage: med.dosage,
              purpose: med.purpose,
              toBeTakenAt: time,
              taken: med
                  .taken, // Will implement per-section tracking later if needed
            ));
          } catch (_) {}
        }
      }

      // Sort by time
      results.sort((a, b) => a.toBeTakenAt.compareTo(b.toBeTakenAt));
      return results;
    });
  }

  @override
  Stream<List<MedicationEntity>> watchAllMedications() {
    return db.medicationsDao.watchAllMedications().map((meds) {
      return meds.where((m) => m.syncStatus != 'pending_delete').map((med) {
        return MedicationEntity(
          id: med.id,
          name: med.name,
          dosage: med.dosage,
          purpose: med.purpose,
          toBeTakenAt: med.toBeTakenAt ?? DateTime.now(), // Fallback
          taken: med.taken,
        );
      }).toList();
    });
  }

  @override
  AsyncResponse<MedicationCount> getCachedMedicationCounts() =>
      _fetchLocalMedicationCounts();

  @override
  AsyncResponse<List<MedicationEntity>> getCachedMedicationsBySection(
          String section) =>
      _fetchLocalMedicationsBySection(section);

  @override
  AsyncResponse<MedicationListResponse> getCachedAllMedications() =>
      _fetchLocalMedications(1, 50);

  @override
  AsyncResponse<MedicationAdherence> getAdherence(
      {required bool showWeekdays}) async {
    if (await connectivityService.isConnected) {
      try {
        MedicationAdherence result =
            await remoteDataSource.getAdherence(showWeekdays: showWeekdays);

        result = await _applyPendingMutationsToAdherenceResult(result);

        // Cache adherence rate.
        final adherenceModel = VitalHistoriesCompanion(
          id: const drift.Value('adherence_cache_key'),
          vitalType: const drift.Value('ADHERENCE_CACHE'),
          vitalName: const drift.Value('Medication Adherence'),
          value: drift.Value(result.rate.toString()),
          unit: const drift.Value('%'),
          severity: const drift.Value('normal'),
          recordedAt: drift.Value(DateTime.now()),
        );

        // Cache adherence days list.
        final daysJson = result.days
            .map((d) => {
                  'id': d.id,
                  'taken': d.taken,
                  'takenAt': d.takenAt.toIso8601String(),
                })
            .toList();
        final fullJson = jsonEncode({'rate': result.rate, 'days': daysJson});
        final adherenceFullModel = VitalHistoriesCompanion(
          id: const drift.Value('adherence_full_cache_key'),
          vitalType: const drift.Value('ADHERENCE_FULL_CACHE'),
          vitalName: const drift.Value('Medication Adherence Full'),
          value: drift.Value(fullJson),
          unit: const drift.Value('json'),
          severity: const drift.Value('normal'),
          recordedAt: drift.Value(DateTime.now()),
        );

        await db.vitalsDao.insertVitals([adherenceModel, adherenceFullModel]);
        return right(result);
      } on ApiException catch (e) {
        return (await _fetchLocalAdherence())
            .fold((_) => left(e.message ?? 'Server error'), right);
      } catch (e) {
        return _fetchLocalAdherence();
      }
    } else {
      return _fetchLocalAdherence();
    }
  }

  @override
  Stream<MedicationAdherence> watchAdherence() {
    return db.vitalsDao
        .watchVitalsByType('ADHERENCE_FULL_CACHE')
        .asyncMap((vitals) async {
      final fullVital = vitals.firstOrNull;
      if (fullVital != null) {
        try {
          final decoded = jsonDecode(fullVital.value);
          final rate = (decoded['rate'] as num).toDouble();
          final daysList = decoded['days'] as List;
          final days = daysList
              .map((d) => AdherenceDay(
                    id: d['id'],
                    taken: d['taken'],
                    takenAt: DateTime.parse(d['takenAt']),
                  ))
              .toList();

          final localResult = MedicationAdherence(rate: rate, days: days);
          return await _applyPendingMutationsToAdherenceResult(localResult);
        } catch (_) {}
      }
      return const MedicationAdherence(rate: 0, days: []);
    });
  }

  AsyncResponse<MedicationAdherence> _fetchLocalAdherence() async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();

      // Parse JSON cache.
      final fullVital = vitals
          .where((v) => v.vitalType == 'ADHERENCE_FULL_CACHE')
          .firstOrNull;
      if (fullVital != null) {
        try {
          final adherence =
              await Isolate.run(() => parseAdherenceJson(fullVital.value));
          return right(adherence);
        } catch (_) {
          // Fallback to basic cache.
        }
      }

      // Fallback basic cache.
      final adherenceVital =
          vitals.where((v) => v.vitalType == 'ADHERENCE_CACHE').firstOrNull;
      double rate = 0.0;
      if (adherenceVital != null) {
        final parsed = double.tryParse(adherenceVital.value) ?? 0.0;
        // Parse fractional rate to percentage.
        rate = (parsed > 0 && parsed <= 1.0) ? parsed * 100 : parsed;
      }

      return right(MedicationAdherence(rate: rate, days: const []));
    } catch (e) {
      return left('Cache failure');
    }
  }

  // Legacy count patching removed (obsolete with Stream watchers)

  @override
  AsyncResponse<MedicationCount> getMedicationCounts() async {
    // We don't actively fetch counts anymore since the UI uses watchMedicationCounts()
    // We just return the local counted state dynamically.
    return _fetchLocalMedicationCounts();
  }

  AsyncResponse<MedicationCount> _fetchLocalMedicationCounts() async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      final countsVital = vitals
          .where((v) => v.vitalType == 'MEDICATION_COUNTS_CACHE_$_todayKey')
          .firstOrNull;
      if (countsVital != null) {
        try {
          final count =
              await Isolate.run(() => parseCountsJson(countsVital.value));
          return right(count);
        } catch (_) {}
      }

      // Fallback to DB count.
      final meds = await db.medicationsDao.getAllMedications();
      int morning = 0, afternoon = 0, evening = 0;
      for (var m in meds) {
        if (m.id.startsWith('offline_')) {
          continue; // Skip optimistic rows to avoid double counting
        }
        final hour = (m.toBeTakenAt ?? DateTime.now()).hour;
        if (hour < 12) {
          morning++;
        } else if (hour < 17) {
          afternoon++;
        } else {
          evening++;
        }
      }
      return right(MedicationCount(
          morning: morning, afternoon: afternoon, evening: evening));
    } catch (e) {
      return left('Cache failure');
    }
  }

  @override
  AsyncResponse<List<MedicationEntity>> getMedicationsBySection(
      String section) async {
    if (await connectivityService.isConnected) {
      try {
        List<MedicationEntity> result =
            await remoteDataSource.getMedicationsBySection(section);
        result = await _applyPendingMutationsToRemoteResult(result,
            sectionFilter: section);

        // Cache data atomically.
        await db.transaction(() async {
          // Cache all medicines locally.
          for (var row in result) {
            await db.medicationsDao
                .insertOrUpdateMedication(MedicationsCompanion(
              id: drift.Value(row.id),
              name: drift.Value(row.name),
              dosage: drift.Value(row.dosage),
              purpose: drift.Value(row.purpose),
              toBeTakenAt: drift.Value(row.toBeTakenAt),
              taken: drift.Value(row.taken),
            ));
          }

          // Cache sectional medicines directly.
          final sectionJson = jsonEncode(result
              .map((m) => {
                    'id': m.id,
                    'name': m.name,
                    'dosage': m.dosage,
                    'purpose': m.purpose,
                    'toBeTakenAt': m.toBeTakenAt.toIso8601String(),
                    'taken': m.taken,
                  })
              .toList());

          final sectionModel = VitalHistoriesCompanion(
            id: drift.Value('med_section_cache_${section}_$_todayKey'),
            vitalType: drift.Value('MED_SECTION_CACHE_${section}_$_todayKey'),
            vitalName: drift.Value('Medications for $section'),
            value: drift.Value(sectionJson),
            unit: const drift.Value('json'),
            severity: const drift.Value('normal'),
            recordedAt: drift.Value(DateTime.now()),
          );
          await db.vitalsDao.insertVitals([sectionModel]);
        });

        return right(result);
      } on ApiException catch (e) {
        return (await _fetchLocalMedicationsBySection(section)).fold(
            (_) => left(e.message ?? 'Server error'),
            (r) async => right(await _applyPendingMutationsToRemoteResult(r,
                sectionFilter: section)));
      } catch (e) {
        return _fetchLocalMedicationsBySection(section).then((res) => res.fold(
            (l) => left(l),
            (r) async => right(await _applyPendingMutationsToRemoteResult(r,
                sectionFilter: section))));
      }
    } else {
      return _fetchLocalMedicationsBySection(section).then((res) => res.fold(
          (l) => left(l),
          (r) async => right(await _applyPendingMutationsToRemoteResult(r,
              sectionFilter: section))));
    }
  }

  AsyncResponse<List<MedicationEntity>> _fetchLocalMedicationsBySection(
      String section) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      final sectionVital = vitals
          .where(
              (v) => v.vitalType == 'MED_SECTION_CACHE_${section}_$_todayKey')
          .firstOrNull;

      if (sectionVital != null) {
        try {
          final sectionEntities = await Isolate.run(
              () => parseSectionMedicationsJson(sectionVital.value));
          return right(sectionEntities);
        } catch (_) {}
      }

      // Fallback to DB query filtering.
      final meds = await db.medicationsDao.getAllMedications();
      final filtered = meds
          .where((m) {
            if (m.id.startsWith('offline_')) {
              return false; // Skip optimistic rows to avoid double counting and wrong times
            }
            final hour = (m.toBeTakenAt ?? DateTime.now()).hour;
            if (section == 'MORNING') return hour < 12;
            if (section == 'AFTERNOON') return hour >= 12 && hour < 17;
            if (section == 'EVENING') return hour >= 17;
            return false;
          })
          .map((m) => MedicationEntity(
                id: m.id,
                name: m.name,
                dosage: m.dosage,
                purpose: m.purpose,
                toBeTakenAt: m.toBeTakenAt ?? DateTime.now(),
                taken: m.taken,
              ))
          .toList();
      return right(filtered);
    } catch (e) {
      return left('Cache failure');
    }
  }

  @override
  AsyncResponse<void> confirmMedication(String medicationId, String section,
      {String? date}) async {
    bool forceOffline = false;
    final effectiveDate =
        date ?? DateTime.now().toIso8601String().split('T')[0];

    if (await connectivityService.isConnected) {
      try {
        await remoteDataSource.confirmMedication(medicationId, section,
            date: effectiveDate);
        return right(null);
      } on NetworkException {
        forceOffline = true;
      } on ApiException catch (e) {
        return left(e.message ?? 'Failed to confirm dose. Please try again.');
      } catch (e) {
        return left(
            'Something went wrong confirming this dose. Please try again.');
      }
    } else {
      forceOffline = true;
    }

    if (forceOffline) {
      // Queue optimistic offline mutation.
      try {
        final pendingAll =
            await db.pendingMutationsDao.getAllPendingMutations();
        final alreadyConfirming = pendingAll.any((p) =>
            p.entityId == medicationId &&
            p.action == 'confirm' &&
            jsonDecode(p.payloadJson)['section'] == section &&
            jsonDecode(p.payloadJson)['date'] == effectiveDate);

        if (!alreadyConfirming) {
          final payload = jsonEncode({
            'medicationId': medicationId,
            'section': section,
            'date': effectiveDate
          });
          await db.pendingMutationsDao.addPendingMutation(
            PendingMutationsCompanion.insert(
              id: const Uuid().v4(),
              entityType: 'medication',
              entityId: medicationId,
              action: 'confirm',
              payloadJson: payload,
              createdAt: DateTime.now(),
            ),
          );
        }
        await db.medicationsDao.markMedicationTaken(medicationId);
        await _markSectionCacheTaken(section, medicationId, effectiveDate);
        await _optimisticallyUpdateAdherence(effectiveDate);

        // Update specific history cache
        try {
          final now = DateTime.now();
          final formattedDate = now.toIso8601String().split('T')[0];
          final vitals = await db.vitalsDao.getAllVitals();
          final historyVital = vitals
              .where(
                  (v) => v.id == 'med_history_${medicationId}_$formattedDate')
              .firstOrNull;

          if (historyVital != null) {
            final decoded =
                jsonDecode(historyVital.value) as Map<String, dynamic>;
            final logs = List<dynamic>.from(decoded['logs'] ?? []);
            logs.add({
              'id': const Uuid().v4(),
              'taken': true,
              'takenAt': now.toIso8601String(),
            });
            decoded['logs'] = logs;
            final currentRate =
                (decoded['adherenceRate'] as num?)?.toDouble() ?? 0.0;
            decoded['adherenceRate'] = (currentRate + 5).clamp(0, 100);

            await db.vitalsDao.insertVitals([
              VitalHistoriesCompanion(
                id: drift.Value('med_history_${medicationId}_$formattedDate'),
                vitalType: const drift.Value('MED_HISTORY_CACHE'),
                vitalName: drift.Value('History for $medicationId'),
                value: drift.Value(jsonEncode(decoded)),
                unit: const drift.Value('json'),
                severity: const drift.Value('normal'),
                recordedAt: drift.Value(now),
              )
            ]);
          }
        } catch (_) {}

        try {
          if (GetIt.instance.isRegistered<MutationSyncManager>()) {
            GetIt.instance<MutationSyncManager>().triggerSync();
          }
        } catch (_) {}

        return right(null); // Optimistic success.
      } catch (e) {
        return left('Cache failure');
      }
    }
    return left('Unexpected state');
  }

  Future<void> _markSectionCacheTaken(
      String section, String medicationId, String effectiveDate) async {
    try {
      if (effectiveDate != _todayKey) return; // Only update today's cache

      final vitals = await db.vitalsDao.getAllVitals();
      final sectionVital = vitals
          .where(
              (v) => v.vitalType == 'MED_SECTION_CACHE_${section}_$_todayKey')
          .firstOrNull;
      if (sectionVital == null) return;

      final decoded = jsonDecode(sectionVital.value) as List;
      final updated = decoded.map((m) {
        final entry = Map<String, dynamic>.from(m as Map);
        if (entry['id'] == medicationId) entry['taken'] = true;
        return entry;
      }).toList();

      await db.vitalsDao.insertVitals([
        VitalHistoriesCompanion(
          id: drift.Value('med_section_cache_${section}_$_todayKey'),
          vitalType: drift.Value('MED_SECTION_CACHE_${section}_$_todayKey'),
          vitalName: drift.Value('Medications for $section'),
          value: drift.Value(jsonEncode(updated)),
          unit: const drift.Value('json'),
          severity: const drift.Value('normal'),
          recordedAt: drift.Value(DateTime.now()),
        ),
      ]);
    } catch (_) {
      // Cache mismatch fallback.
    }
  }

  Future<void> _optimisticallyUpdateAdherence([String? targetDate]) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();

      // Update basic adherence rate cache
      final adherenceVital =
          vitals.where((v) => v.vitalType == 'ADHERENCE_CACHE').firstOrNull;
      double newRate = 0.0;
      if (adherenceVital != null) {
        final parsed = double.tryParse(adherenceVital.value) ?? 0.0;
        newRate = (parsed > 0 && parsed <= 1.0) ? parsed * 100 : parsed;
        newRate = (newRate + 5).clamp(0, 100); // Bump by 5%
        await db.vitalsDao.insertVitals([
          VitalHistoriesCompanion(
            id: const drift.Value('adherence_cache_key'),
            vitalType: const drift.Value('ADHERENCE_CACHE'),
            vitalName: const drift.Value('Medication Adherence'),
            value: drift.Value(newRate.toString()),
            unit: const drift.Value('%'),
            severity: const drift.Value('normal'),
            recordedAt: drift.Value(DateTime.now()),
          ),
        ]);
      }

      // Update full adherence cache
      final fullVital = vitals
          .where((v) => v.vitalType == 'ADHERENCE_FULL_CACHE')
          .firstOrNull;
      if (fullVital != null) {
        final decoded = jsonDecode(fullVital.value) as Map<String, dynamic>;
        decoded['rate'] = newRate;

        // Optimistically set the date to taken if days exist
        if (decoded['days'] != null) {
          final daysList = List<dynamic>.from(decoded['days']);
          final dateStr =
              targetDate ?? DateTime.now().toIso8601String().substring(0, 10);

          for (var day in daysList) {
            if (day is Map &&
                day['takenAt'] != null &&
                day['takenAt'].toString().startsWith(dateStr)) {
              day['taken'] = true;
            }
          }
          decoded['days'] = daysList;
        }

        await db.vitalsDao.insertVitals([
          VitalHistoriesCompanion(
            id: const drift.Value('adherence_full_cache_key'),
            vitalType: const drift.Value('ADHERENCE_FULL_CACHE'),
            vitalName: const drift.Value('Medication Adherence Full'),
            value: drift.Value(jsonEncode(decoded)),
            unit: const drift.Value('json'),
            severity: const drift.Value('normal'),
            recordedAt: drift.Value(DateTime.now()),
          ),
        ]);
      }
    } catch (_) {}
  }

  Future<List<MedicationEntity>> _applyPendingMutationsToRemoteResult(
      List<MedicationEntity> remoteResult,
      {String? sectionFilter}) async {
    try {
      final pendingAll = await db.pendingMutationsDao.getAllPendingMutations();
      final pendingMeds =
          pendingAll.where((p) => p.entityType == 'medication').toList();

      if (pendingMeds.isEmpty) return remoteResult;

      List<MedicationEntity> result = List.from(remoteResult);

      for (var pending in pendingMeds) {
        if (pending.action == 'confirm') {
          final index = result.indexWhere((m) => m.id == pending.entityId);
          if (index != -1) {
            try {
              final payload = jsonDecode(pending.payloadJson);
              final confirmDate = payload['date'] as String?;
              if (confirmDate != null) {
                final targetDateStr =
                    result[index].toBeTakenAt.toIso8601String();
                if (targetDateStr.startsWith(confirmDate)) {
                  result[index] = result[index].copyWith(taken: true);
                }
              } else {
                // Fallback for old mutations without date
                result[index] = result[index].copyWith(taken: true);
              }
            } catch (_) {
              result[index] = result[index].copyWith(taken: true);
            }
          }
        }
      }

      return result;
    } catch (_) {
      return remoteResult;
    }
  }

  Future<MedicationAdherence> _applyPendingMutationsToAdherenceResult(
      MedicationAdherence remoteResult) async {
    try {
      final pendingAll = await db.pendingMutationsDao.getAllPendingMutations();
      final pendingConfirms = pendingAll
          .where((p) => p.entityType == 'medication' && p.action == 'confirm')
          .toList();

      if (pendingConfirms.isEmpty) return remoteResult;

      double newRate = remoteResult.rate;
      List<AdherenceDay> newDays = List.from(remoteResult.days);

      for (var pending in pendingConfirms) {
        try {
          final payload = jsonDecode(pending.payloadJson);
          final confirmDate = payload['date'] as String?;
          final dateStr =
              confirmDate ?? DateTime.now().toIso8601String().substring(0, 10);

          for (int i = 0; i < newDays.length; i++) {
            if (newDays[i].takenAt.toIso8601String().startsWith(dateStr)) {
              if (!newDays[i].taken) {
                newDays[i] = AdherenceDay(
                  id: newDays[i].id,
                  taken: true,
                  takenAt: newDays[i].takenAt,
                );
                // Rough estimate bump for offline adherence view
                newRate = (newRate + 5).clamp(0, 100).toDouble();
              }
            }
          }
        } catch (_) {}
      }

      return MedicationAdherence(rate: newRate, days: newDays);
    } catch (_) {
      return remoteResult;
    }
  }

  // Pagination cache keys.
  final Map<String, DateTime> _lastFetchTimeByPage = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  AsyncResponse<MedicationListResponse> getAllMedications(
      {int page = 1, int pageSize = 10, bool forceRefresh = false}) async {
    if (await connectivityService.isConnected) {
      final pageCacheKey = '$page-$pageSize';

      // Verify cache freshness.
      if (!forceRefresh && _lastFetchTimeByPage[pageCacheKey] != null) {
        final now = DateTime.now();
        if (now.difference(_lastFetchTimeByPage[pageCacheKey]!) <
            _cacheDuration) {
          debugPrint(
              "Skipping remote fetch for Medications page $page. Cache is fresh.");
          return _fetchLocalMedications(page, pageSize);
        }
      }

      try {
        MedicationListResponse result = await remoteDataSource
            .getAllMedications(page: page, pageSize: pageSize);

        final patchedRows =
            await _applyPendingMutationsToRemoteResult(result.rows);
        result = MedicationListResponse(
          rows: patchedRows,
          total: result.total + (patchedRows.length - result.rows.length),
          pageSize: result.pageSize,
          page: result.page,
          totalPages: result.totalPages,
        );

        // Upsert medications to avoid wiping other pages.
        for (var row in result.rows) {
          await db.medicationsDao.insertOrUpdateMedication(MedicationsCompanion(
            id: drift.Value(row.id),
            name: drift.Value(row.name),
            dosage: drift.Value(row.dosage),
            purpose: drift.Value(row.purpose),
            toBeTakenAt: drift.Value(row.toBeTakenAt),
            taken: drift.Value(row.taken),
          ));
        }

        _lastFetchTimeByPage[pageCacheKey] = DateTime.now();
        return right(result);
      } on ApiException catch (e) {
        return (await _fetchLocalMedications(page, pageSize))
            .fold((_) => left(e.message ?? 'Server error'), right);
      } catch (e) {
        return _fetchLocalMedications(page, pageSize);
      }
    } else {
      return _fetchLocalMedications(page, pageSize);
    }
  }

  AsyncResponse<MedicationListResponse> _fetchLocalMedications(
      int page, int pageSize) async {
    try {
      final localMeds = await db.medicationsDao.getAllMedications();

      final start = (page - 1) * pageSize;
      final pageRows = start >= localMeds.length
          ? <Medication>[]
          : localMeds.sublist(
              start, (start + pageSize).clamp(0, localMeds.length));

      final entities = pageRows
          .map((m) => MedicationEntity(
                id: m.id,
                name: m.name,
                dosage: m.dosage,
                purpose: m.purpose,
                toBeTakenAt: m.toBeTakenAt ?? DateTime.now(),
                taken: m.taken,
              ))
          .toList();

      return right(MedicationListResponse(
        rows: entities,
        total: localMeds.length,
        pageSize: pageSize,
        page: page,
        totalPages:
            localMeds.isEmpty ? 1 : (localMeds.length / pageSize).ceil(),
      ));
    } catch (e) {
      return left('Cache failure');
    }
  }

  @override
  AsyncResponse<MedicationHistoryEntity> getMedicationHistory(
      String medicationId,
      {required String date}) async {
    if (await connectivityService.isConnected) {
      try {
        final result = await remoteDataSource.getMedicationHistory(medicationId,
            date: date);

        // Cache history locally.
        final logsJson = result.logs
            .map((l) => {
                  'id': l.id,
                  'taken': l.taken,
                  'takenAt': l.takenAt.toIso8601String(),
                })
            .toList();
        final historyJson = jsonEncode({
          'medicationName': result.medicationName,
          'adherenceRate': result.adherenceRate,
          'logs': logsJson,
        });

        final historyModel = VitalHistoriesCompanion(
          id: drift.Value('med_history_${medicationId}_$date'),
          vitalType: const drift.Value('MED_HISTORY_CACHE'),
          vitalName: drift.Value('History for $medicationId'),
          value: drift.Value(historyJson),
          unit: const drift.Value('json'),
          severity: const drift.Value('normal'),
          recordedAt: drift.Value(DateTime.now()),
        );
        await db.vitalsDao.insertVitals([historyModel]);

        return right(result);
      } on ApiException catch (e) {
        return (await _fetchLocalMedicationHistory(medicationId, date))
            .fold((_) => left(e.message ?? 'Server error'), right);
      } catch (e) {
        return _fetchLocalMedicationHistory(medicationId, date);
      }
    } else {
      return _fetchLocalMedicationHistory(medicationId, date);
    }
  }

  AsyncResponse<MedicationHistoryEntity> _fetchLocalMedicationHistory(
      String medicationId, String date) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      final cacheKey = 'med_history_${medicationId}_$date';
      final historyVital = vitals.where((v) => v.id == cacheKey).firstOrNull;

      if (historyVital != null) {
        try {
          final history =
              await Isolate.run(() => parseHistoryJson(historyVital.value));
          return right(history);
        } catch (_) {}
      }

      final localMeds = await db.medicationsDao.getAllMedications();
      final target = localMeds.where((m) => m.id == medicationId).firstOrNull;
      if (target != null) {
        // Return placeholder for missing logs.
        return right(MedicationHistoryEntity(
          medicationName: target.name,
          adherenceRate: 0,
          logs: const [],
        ));
      }
      return left('Cache failure');
    } catch (e) {
      return left('Cache failure');
    }
  }

  // Removed duplicate watchAllMedications

  @override
  void invalidateCache() {
    _lastFetchTimeByPage.clear();
  }

  @override
  AsyncResponse<String> createMedication(CreateMedicationModel data) async {
    try {
      final localId = 'offline_${const Uuid().v4()}';
      final companion = MedicationsCompanion(
        id: drift.Value(localId),
        name: drift.Value(data.name),
        dosage: drift.Value(data.dosage),
        purpose: drift.Value(data.notes ?? ''),
        morningSchedule: drift.Value(
            data.morning != null ? jsonEncode(data.morning!.toJson()) : null),
        afternoonSchedule: drift.Value(data.afternoon != null
            ? jsonEncode(data.afternoon!.toJson())
            : null),
        eveningSchedule: drift.Value(
            data.evening != null ? jsonEncode(data.evening!.toJson()) : null),
        syncStatus: const drift.Value('pending_create'),
        lastModifiedAt: drift.Value(DateTime.now()),
      );

      await db.transaction(() async {
        await db.medicationsDao.insertOrUpdateMedication(companion);
        await db.pendingMutationsDao.addPendingMutation(
          PendingMutationsCompanion.insert(
            id: const Uuid().v4(),
            entityType: 'medication',
            entityId: localId,
            action: 'create_medication',
            payloadJson: jsonEncode(data.toJson()),
            createdAt: DateTime.now(),
          ),
        );
      });

      try {
        if (GetIt.instance.isRegistered<MutationSyncManager>()) {
          GetIt.instance<MutationSyncManager>().triggerSync();
        }
      } catch (_) {}

      return right(localId);
    } catch (e) {
      return left('Failed to create medication locally');
    }
  }

  @override
  AsyncResponse<MedicationDetailModel> getMedicationById(String id) async {
    try {
      final localMeds = await db.medicationsDao.getAllMedications();
      final target = localMeds.where((m) => m.id == id).firstOrNull;
      if (target == null) return left('Not found in cache');

      DosingScheduleModel? parseSchedule(String? jsonStr) {
        if (jsonStr == null || jsonStr == 'null' || jsonStr.isEmpty)
          return null;
        try {
          dynamic decoded = jsonDecode(jsonStr);
          if (decoded is String) {
            decoded = jsonDecode(decoded); // Handle double encoded
          }
          if (decoded is Map<String, dynamic>) {
            return DosingScheduleModel.fromJson(decoded);
          }
        } catch (e) {
          debugPrint('Failed to parse schedule: $jsonStr, Error: $e');
        }
        return null;
      }

      return right(MedicationDetailModel(
        id: target.id,
        name: target.name,
        dosage: target.dosage,
        notes: target.purpose,
        morning: parseSchedule(target.morningSchedule),
        afternoon: parseSchedule(target.afternoonSchedule),
        evening: parseSchedule(target.eveningSchedule),
        createdAt: target.lastModifiedAt ?? DateTime.now(),
        updatedAt: target.lastModifiedAt ?? DateTime.now(),
      ));
    } catch (e, stack) {
      debugPrint('Cache failure in getMedicationById for id $id: $e\n$stack');
      return left('Cache failure');
    }
  }

  @override
  AsyncResponse<String> updateMedication(
      String id, UpdateMedicationModel data) async {
    try {
      final localMeds = await db.medicationsDao.getAllMedications();
      final local = localMeds.where((m) => m.id == id).firstOrNull;
      if (local == null) return left('Medication not found locally');

      final companion = MedicationsCompanion(
        id: drift.Value(id),
        name: drift.Value(local.name),
        dosage: drift.Value(data.dosage ?? local.dosage),
        purpose: drift.Value(data.notes ?? local.purpose),
        morningSchedule: drift.Value(
            data.morning != null ? jsonEncode(data.morning!.toJson()) : null),
        afternoonSchedule: drift.Value(data.afternoon != null
            ? jsonEncode(data.afternoon!.toJson())
            : null),
        eveningSchedule: drift.Value(
            data.evening != null ? jsonEncode(data.evening!.toJson()) : null),
        syncStatus: drift.Value(local.syncStatus == 'pending_create'
            ? 'pending_create'
            : 'pending_update'),
        lastModifiedAt: drift.Value(DateTime.now()),
      );

      await db.transaction(() async {
        await db.medicationsDao.insertOrUpdateMedication(companion);
        await db.pendingMutationsDao.addPendingMutation(
          PendingMutationsCompanion.insert(
            id: const Uuid().v4(),
            entityType: 'medication',
            entityId: id,
            action: 'update_medication',
            payloadJson: jsonEncode(data.toJson()),
            createdAt: DateTime.now(),
          ),
        );
      });

      try {
        if (GetIt.instance.isRegistered<MutationSyncManager>()) {
          GetIt.instance<MutationSyncManager>().triggerSync();
        }
      } catch (_) {}

      return right(id);
    } catch (e) {
      return left('Failed to update medication locally');
    }
  }

  @override
  AsyncResponse<SeededMedicationListResponseModel> getPreloadedMedications(
      {int page = 1, int limit = 10, String? search}) async {
    if (await connectivityService.isConnected) {
      try {
        final res = await remoteDataSource.getPreloadedMedications(
            page: page, limit: limit, search: search);
        return right(res);
      } on ApiException catch (e) {
        return left(e.message ?? 'Server error');
      } catch (e) {
        return left(e.toString());
      }
    } else {
      return left('No internet connection');
    }
  }
}
