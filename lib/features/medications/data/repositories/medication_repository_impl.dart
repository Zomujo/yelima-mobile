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

  @override
  AsyncResponse<MedicationCount> getMedicationCounts() async {
    if (await connectivityService.isConnected) {
      try {
        final result = await remoteDataSource.getMedicationCounts();

        // Cache medication counts.
        final countsJson = jsonEncode({
          'morning': result.morning,
          'afternoon': result.afternoon,
          'evening': result.evening,
        });
        final countsModel = VitalHistoriesCompanion(
          id: drift.Value('medication_counts_cache_key_$_todayKey'),
          vitalType: drift.Value('MEDICATION_COUNTS_CACHE_$_todayKey'),
          vitalName: const drift.Value('Medication Counts'),
          value: drift.Value(countsJson),
          unit: const drift.Value('json'),
          severity: const drift.Value('normal'),
          recordedAt: drift.Value(DateTime.now()),
        );
        await db.vitalsDao.insertVitals([countsModel]);

        return right(result);
      } on ApiException catch (e) {
        return (await _fetchLocalMedicationCounts())
            .fold((_) => left(e.message ?? 'Server error'), right);
      } catch (e) {
        return _fetchLocalMedicationCounts();
      }
    } else {
      return _fetchLocalMedicationCounts();
    }
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
        final hour = m.toBeTakenAt.hour;
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
        return (await _fetchLocalMedicationsBySection(section))
            .fold((_) => left(e.message ?? 'Server error'), right);
      } catch (e) {
        return _fetchLocalMedicationsBySection(section);
      }
    } else {
      return _fetchLocalMedicationsBySection(section);
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
            final hour = m.toBeTakenAt.hour;
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
                toBeTakenAt: m.toBeTakenAt,
                taken: m.taken,
              ))
          .toList();
      return right(filtered);
    } catch (e) {
      return left('Cache failure');
    }
  }

  @override
  AsyncResponse<void> confirmMedication(
      String medicationId, String section, {String? date}) async {
    bool forceOffline = false;
    final effectiveDate = date ?? DateTime.now().toIso8601String().split('T')[0];
    
    if (await connectivityService.isConnected) {
      try {
        await remoteDataSource.confirmMedication(medicationId, section, date: effectiveDate);
        return right(null);
      } on ApiException catch (e) {
        if (e.message != null && e.message!.contains('400')) {
          return left(e.message!);
        }
        forceOffline = true;
      } catch (e) {
        forceOffline = true;
      }
    } else {
      forceOffline = true;
    }

    if (forceOffline) {
      // Queue optimistic offline mutation.
      try {
        final pendingAll =
            await db.pendingMutationsDao.getAllPendingMutations();
        final alreadyConfirming = pendingAll
            .any((p) => p.entityId == medicationId && p.action == 'confirm');

        if (!alreadyConfirming) {
          final payload =
              jsonEncode({'medicationId': medicationId, 'section': section, 'date': effectiveDate});
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
        // Persist confirmation locally.
        await db.medicationsDao.markMedicationTaken(medicationId);
        await _markSectionCacheTaken(section, medicationId);
        await _optimisticallyUpdateAdherence();

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
      String section, String medicationId) async {
    try {
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

  Future<void> _insertSectionCacheMedication(
      CreateMedicationModel data, String localId) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      final now = DateTime.now();

      final schedules = {
        if (data.morning != null) 'MORNING': data.morning!.time,
        if (data.afternoon != null) 'AFTERNOON': data.afternoon!.time,
        if (data.evening != null) 'EVENING': data.evening!.time,
      };

      for (var entry in schedules.entries) {
        final section = entry.key;

        final sectionVital = vitals
            .where(
                (v) => v.vitalType == 'MED_SECTION_CACHE_${section}_$_todayKey')
            .firstOrNull;

        List<dynamic> updated = [];
        if (sectionVital != null) {
          updated = jsonDecode(sectionVital.value) as List<dynamic>;
        }

        updated.add({
          'id': localId,
          'name': data.name,
          'dosage': data.dosage,
          'purpose': data.notes ?? '',
          'toBeTakenAt': now.toIso8601String(), // Offline placeholder
          'taken': false,
        });

        await db.vitalsDao.insertVitals([
          VitalHistoriesCompanion(
            id: drift.Value('med_section_cache_${section}_$_todayKey'),
            vitalType: drift.Value('MED_SECTION_CACHE_${section}_$_todayKey'),
            vitalName: drift.Value('Medications for $section'),
            value: drift.Value(jsonEncode(updated)),
            unit: const drift.Value('json'),
            severity: const drift.Value('normal'),
            recordedAt: drift.Value(now),
          ),
        ]);
      }
    } catch (_) {}
  }

  Future<void> _updateSectionCacheMedication(
      String id, UpdateMedicationModel data) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      for (final section in ['MORNING', 'AFTERNOON', 'EVENING']) {
        final sectionVital = vitals
            .where(
                (v) => v.vitalType == 'MED_SECTION_CACHE_${section}_$_todayKey')
            .firstOrNull;
        if (sectionVital != null) {
          final decoded = jsonDecode(sectionVital.value) as List;
          bool found = false;
          final updated = decoded.map((m) {
            final entry = Map<String, dynamic>.from(m as Map);
            if (entry['id'] == id) {
              if (data.dosage != null) entry['dosage'] = data.dosage;
              if (data.notes != null) entry['purpose'] = data.notes;
              found = true;
            }
            return entry;
          }).toList();

          if (found) {
            await db.vitalsDao.insertVitals([
              VitalHistoriesCompanion(
                id: drift.Value('med_section_cache_${section}_$_todayKey'),
                vitalType:
                    drift.Value('MED_SECTION_CACHE_${section}_$_todayKey'),
                vitalName: drift.Value('Medications for $section'),
                value: drift.Value(jsonEncode(updated)),
                unit: const drift.Value('json'),
                severity: const drift.Value('normal'),
                recordedAt: drift.Value(DateTime.now()),
              ),
            ]);
            break; // Stop searching once found
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _optimisticallyUpdateAdherence() async {
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

        // Optimistically set today to taken if days exist
        if (decoded['days'] != null) {
          final daysList = List<dynamic>.from(decoded['days']);
          final todayStr = DateTime.now().toIso8601String().substring(0, 10);

          for (var day in daysList) {
            if (day is Map &&
                day['takenAt'] != null &&
                day['takenAt'].toString().startsWith(todayStr)) {
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
            result[index] = result[index].copyWith(taken: true);
          }
        } else if (pending.action == 'update_medication') {
          final index = result.indexWhere((m) => m.id == pending.entityId);
          if (index != -1) {
            final payload = jsonDecode(pending.payloadJson);
            result[index] = result[index].copyWith(
              dosage: payload['dosage'] as String?,
              purpose: payload['notes'] as String?,
            );
          }
        } else if (pending.action == 'create_medication') {
          final meds = await db.medicationsDao.getAllMedications();
          final localMed =
              meds.where((m) => m.id == pending.entityId).firstOrNull;

          if (localMed != null) {
            bool matchesSection = true;
            if (sectionFilter != null) {
              final hour = localMed.toBeTakenAt.hour;
              if (sectionFilter == 'MORNING' && hour >= 12) {
                matchesSection = false;
              }
              if (sectionFilter == 'AFTERNOON' && (hour < 12 || hour >= 17)) {
                matchesSection = false;
              }
              if (sectionFilter == 'EVENING' && hour < 17) {
                matchesSection = false;
              }
            }

            if (matchesSection && !result.any((m) => m.id == localMed.id)) {
              result.add(MedicationEntity(
                id: localMed.id,
                name: localMed.name,
                dosage: localMed.dosage,
                purpose: localMed.purpose,
                toBeTakenAt: localMed.toBeTakenAt,
                taken: localMed.taken,
              ));
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

      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      List<AdherenceDay> newDays = List.from(remoteResult.days);

      double newRate = remoteResult.rate;
      newRate = (newRate + 5).clamp(0, 100).toDouble();

      for (int i = 0; i < newDays.length; i++) {
        if (newDays[i].takenAt.toIso8601String().startsWith(todayStr)) {
          newDays[i] = AdherenceDay(
            id: newDays[i].id,
            taken: true,
            takenAt: newDays[i].takenAt,
          );
        }
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
                toBeTakenAt: m.toBeTakenAt,
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

  @override
  Stream<List<MedicationEntity>> watchAllMedications() {
    return db.medicationsDao.watchAllMedications().map((localMeds) {
      return localMeds
          .map((m) => MedicationEntity(
                id: m.id,
                name: m.name,
                dosage: m.dosage,
                purpose: m.purpose,
                toBeTakenAt: m.toBeTakenAt,
                taken: m.taken,
              ))
          .toList();
    });
  }

  @override
  void invalidateCache() {
    _lastFetchTimeByPage.clear();
  }

  @override
  AsyncResponse<String> createMedication(CreateMedicationModel data) async {
    bool forceOffline = false;
    if (await connectivityService.isConnected) {
      try {
        final res = await remoteDataSource.createMedication(data);
        return right(res);
      } on ApiException catch (e) {
        if (e.message != null && e.message!.contains('400')) {
          return left(e.message!);
        }
        forceOffline = true;
      } catch (e) {
        forceOffline = true;
      }
    } else {
      forceOffline = true;
    }

    if (forceOffline) {
      // Queue optimistic offline mutation. for creation
      final localId = 'offline_${const Uuid().v4()}';
      final now = DateTime.now();

      // Build and cache the full MedicationDetailModel so the details screen works offline
      final detail = MedicationDetailModel(
        id: localId,
        name: data.name,
        dosage: data.dosage,
        notes: data.notes,
        morning: data.morning,
        afternoon: data.afternoon,
        evening: data.evening,
        createdAt: now,
        updatedAt: now,
      );

      await db.vitalsDao.insertVitals([
        VitalHistoriesCompanion(
          id: drift.Value('med_detail_cache_$localId'),
          vitalType: const drift.Value('MED_DETAIL_CACHE'),
          vitalName: drift.Value('Detail for $localId'),
          value: drift.Value(jsonEncode(detail.toJson())),
          unit: const drift.Value('json'),
          severity: const drift.Value('normal'),
          recordedAt: drift.Value(now),
        )
      ]);

      // Save optimistic view.
      await db.medicationsDao.insertOrUpdateMedication(MedicationsCompanion(
        id: drift.Value(localId),
        name: drift.Value(data.name),
        dosage: drift.Value(data.dosage),
        purpose: drift.Value(data.notes ?? ''),
        toBeTakenAt: drift.Value(now), // Rough placeholder
        taken: const drift.Value(false),
      ));

      await _insertSectionCacheMedication(data, localId);

      // Queue background mutation.
      final mutationId = const Uuid().v4();
      await db.pendingMutationsDao.addPendingMutation(
        PendingMutationsCompanion.insert(
          id: mutationId,
          entityType: 'medication',
          entityId: localId,
          action: 'create_medication',
          payloadJson: jsonEncode(data.toJson()),
          createdAt: DateTime.now(),
        ),
      );

      try {
        if (GetIt.instance.isRegistered<MutationSyncManager>()) {
          GetIt.instance<MutationSyncManager>().triggerSync();
        }
      } catch (_) {}

      return right(localId);
    }
    return left('Unexpected state');
  }

  @override
  AsyncResponse<MedicationDetailModel> getMedicationById(String id) async {
    if (await connectivityService.isConnected) {
      try {
        final res = await remoteDataSource.getMedicationById(id);

        await db.vitalsDao.insertVitals([
          VitalHistoriesCompanion(
            id: drift.Value('med_detail_cache_$id'),
            vitalType: const drift.Value('MED_DETAIL_CACHE'),
            vitalName: drift.Value('Detail for $id'),
            value: drift.Value(jsonEncode(res.toJson())),
            unit: const drift.Value('json'),
            severity: const drift.Value('normal'),
            recordedAt: drift.Value(DateTime.now()),
          )
        ]);

        return right(res);
      } on ApiException catch (e) {
        return (await _fetchLocalMedicationById(id))
            .fold((_) => left(e.message ?? 'Server error'), right);
      } catch (e) {
        return _fetchLocalMedicationById(id);
      }
    } else {
      return _fetchLocalMedicationById(id);
    }
  }

  AsyncResponse<MedicationDetailModel> _fetchLocalMedicationById(
      String id) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      final detailVital =
          vitals.where((v) => v.id == 'med_detail_cache_$id').firstOrNull;

      if (detailVital != null) {
        try {
          final detail = MedicationDetailModel.fromJson(
              jsonDecode(detailVital.value) as Map<String, dynamic>);
          return right(detail);
        } catch (_) {}
      }

      final localMeds = await db.medicationsDao.getAllMedications();
      final target = localMeds.where((m) => m.id == id).firstOrNull;
      if (target == null) return left('Cache failure');

      // Best-effort detail reconstruction from local cache.
      return right(MedicationDetailModel(
        id: target.id,
        name: target.name,
        dosage: target.dosage,
        notes: target.purpose,
        createdAt: target.toBeTakenAt,
        updatedAt: target.toBeTakenAt,
      ));
    } catch (e) {
      return left('Cache failure');
    }
  }

  @override
  AsyncResponse<String> updateMedication(
      String id, UpdateMedicationModel data) async {
    bool forceOffline = false;
    if (await connectivityService.isConnected) {
      try {
        final res = await remoteDataSource.updateMedication(id, data);
        return right(res);
      } on ApiException catch (e) {
        if (e.message != null && e.message!.contains('400')) {
          return left(e.message!);
        }
        forceOffline = true;
      } catch (e) {
        forceOffline = true;
      }
    } else {
      forceOffline = true;
    }

    if (forceOffline) {
      try {
        // Fetch local cache.
        final localMeds = await db.medicationsDao.getAllMedications();
        final local = localMeds.where((m) => m.id == id).firstOrNull;

        if (local != null) {
          // Optimistic local update (schedule edits await sync).
          await db.medicationsDao.insertOrUpdateMedication(MedicationsCompanion(
            id: drift.Value(id),
            name: drift.Value(local.name),
            dosage: drift.Value(data.dosage ?? local.dosage),
            purpose: drift.Value(data.notes ?? local.purpose),
            toBeTakenAt: drift.Value(local.toBeTakenAt),
            taken: drift.Value(local.taken),
          ));
        }

        // Update detail cache regardless of localMeds
        final vitals = await db.vitalsDao.getAllVitals();
        final detailVital =
            vitals.where((v) => v.id == 'med_detail_cache_$id').firstOrNull;
        if (detailVital != null) {
          final oldDetail = MedicationDetailModel.fromJson(
              jsonDecode(detailVital.value) as Map<String, dynamic>);
          final newDetail = oldDetail.copyWith(
            dosage: data.dosage ?? oldDetail.dosage,
            notes: data.notes ?? oldDetail.notes,
            updatedAt: DateTime.now(),
          );

          await db.vitalsDao.insertVitals([
            VitalHistoriesCompanion(
              id: drift.Value('med_detail_cache_$id'),
              vitalType: const drift.Value('MED_DETAIL_CACHE'),
              vitalName: drift.Value('Detail for $id'),
              value: drift.Value(jsonEncode(newDetail.toJson())),
              unit: const drift.Value('json'),
              severity: const drift.Value('normal'),
              recordedAt: drift.Value(DateTime.now()),
            )
          ]);
        }

        await _updateSectionCacheMedication(id, data);

        // Queue background mutation.
        final mutationId = const Uuid().v4();
        await db.pendingMutationsDao.addPendingMutation(
          PendingMutationsCompanion.insert(
            id: mutationId,
            entityType: 'medication',
            entityId: id,
            action: 'update_medication',
            payloadJson: jsonEncode(data.toJson()),
            createdAt: DateTime.now(),
          ),
        );

        try {
          if (GetIt.instance.isRegistered<MutationSyncManager>()) {
            GetIt.instance<MutationSyncManager>().triggerSync();
          }
        } catch (_) {}

        return right(id);
      } catch (e) {
        return left('Offline update failed');
      }
    }
    return left('Unexpected state');
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
