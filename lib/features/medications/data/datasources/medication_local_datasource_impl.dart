import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/utils/custom_types.dart';
import '../../domain/entities/medication_adherence.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_history_entity.dart';
import '../models/medication_detail_model.dart';
import '../models/dosing_schedule_model.dart';

import '../utils/medication_isolate_parsers.dart';
import '../../utils/medication_local_datasource_helpers.dart';
import '../../utils/medication_optimistic_sync_helpers.dart';
import 'package:drift/drift.dart' as drift;
import 'medication_local_datasource.dart';

class MedicationLocalDataSourceImpl
    with MedicationLocalDataSourceHelpers, MedicationOptimisticSyncHelpers
    implements MedicationLocalDataSource {
  @override
  final AppDatabase db;

  MedicationLocalDataSourceImpl({required this.db});

  String get _todayKey => DateTime.now().toIso8601String().substring(0, 10);

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

        final time = parseScheduleTime(scheduleJson);
        if (time != null) {
          results.add(mapToEntity(med).copyWith(toBeTakenAt: time));
        }
      }

      results.sort((a, b) => a.toBeTakenAt.compareTo(b.toBeTakenAt));
      return results;
    });
  }

  @override
  Stream<List<MedicationEntity>> watchAllMedications() {
    return db.medicationsDao.watchAllMedications().map((meds) => meds
        .where((m) => m.syncStatus != 'pending_delete')
        .map(mapToEntity)
        .toList());
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
          final localResult = MedicationAdherence(
              rate: (decoded['rate'] as num).toDouble(),
              days: (decoded['days'] as List)
                  .map((d) => AdherenceDay(
                        id: d['id'],
                        taken: d['taken'],
                        takenAt: DateTime.parse(d['takenAt']),
                      ))
                  .toList());
          return await applyPendingMutationsToAdherenceResult(localResult);
        } catch (_) {}
      }
      return const MedicationAdherence(rate: 0, days: []);
    });
  }

  @override
  AsyncResponse<MedicationAdherence> getCachedAdherence() async {
    try {
      final adherence = await readVitalCache<MedicationAdherence>(
          'ADHERENCE_FULL_CACHE', parseAdherenceJson,
          byType: true);
      if (adherence != null) return right(adherence);

      final vitals = await db.vitalsDao.getAllVitals();
      final adherenceVital =
          vitals.where((v) => v.vitalType == 'ADHERENCE_CACHE').firstOrNull;
      double rate = 0.0;
      if (adherenceVital != null) {
        final parsed = double.tryParse(adherenceVital.value) ?? 0.0;
        rate = (parsed > 0 && parsed <= 1.0) ? parsed * 100 : parsed;
      }
      return right(MedicationAdherence(rate: rate, days: const []));
    } catch (e) {
      return left('Cache failure');
    }
  }

  @override
  Future<void> cacheAdherence(MedicationAdherence result) async {
    await db.transaction(() async {
      await cacheVital(
          id: 'adherence_cache_key',
          type: 'ADHERENCE_CACHE',
          name: 'Medication Adherence',
          value: result.rate.toString(),
          unit: '%');

      final daysJson = result.days
          .map((d) => {
                'id': d.id,
                'taken': d.taken,
                'takenAt': d.takenAt.toIso8601String()
              })
          .toList();
      await cacheVital(
          id: 'adherence_full_cache_key',
          type: 'ADHERENCE_FULL_CACHE',
          name: 'Medication Adherence Full',
          value: jsonEncode({'rate': result.rate, 'days': daysJson}));
    });
  }

  @override
  AsyncResponse<MedicationCount> getCachedMedicationCounts() async {
    try {
      final count = await readVitalCache<MedicationCount>(
          'MEDICATION_COUNTS_CACHE_$_todayKey', parseCountsJson,
          byType: true);
      if (count != null) return right(count);

      final meds = await db.medicationsDao.getAllMedications();
      int morning = 0, afternoon = 0, evening = 0;
      for (var m in meds) {
        if (m.id.startsWith('offline_')) continue;
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
  AsyncResponse<List<MedicationEntity>> getCachedMedicationsBySection(
      String section) async {
    try {
      final sectionEntities = await readVitalCache<List<MedicationEntity>>(
          'MED_SECTION_CACHE_${section}_$_todayKey',
          parseSectionMedicationsJson,
          byType: true);
      if (sectionEntities != null) return right(sectionEntities);

      final meds = await db.medicationsDao.getAllMedications();
      final filtered = meds
          .where((m) {
            if (m.id.startsWith('offline_')) return false;
            final hour = (m.toBeTakenAt ?? DateTime.now()).hour;
            if (section == 'MORNING') return hour < 12;
            if (section == 'AFTERNOON') return hour >= 12 && hour < 17;
            if (section == 'EVENING') return hour >= 17;
            return false;
          })
          .map(mapToEntity)
          .toList();
      return right(filtered);
    } catch (e) {
      return left('Cache failure');
    }
  }

  @override
  Future<void> cacheMedicationsBySection(
      String section, List<MedicationEntity> result) async {
    await db.transaction(() async {
      await cacheAllMedications(result); // Reuse caching

      final sectionJson = jsonEncode(result
          .map((m) => {
                'id': m.id,
                'name': m.name,
                'dosage': m.dosage,
                'purpose': m.purpose,
                'toBeTakenAt': m.toBeTakenAt.toIso8601String(),
                'taken': m.taken
              })
          .toList());

      await cacheVital(
          id: 'med_section_cache_${section}_$_todayKey',
          type: 'MED_SECTION_CACHE_${section}_$_todayKey',
          name: 'Medications for $section',
          value: sectionJson);
    });
  }

  @override
  AsyncResponse<MedicationListResponse> getCachedAllMedications(
      int page, int pageSize) async {
    try {
      final localMeds = await db.medicationsDao.getAllMedications();
      final start = (page - 1) * pageSize;
      final pageRows = start >= localMeds.length
          ? <Medication>[]
          : localMeds.sublist(
              start, (start + pageSize).clamp(0, localMeds.length));

      return right(MedicationListResponse(
        rows: pageRows.map(mapToEntity).toList(),
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
  Future<void> cacheAllMedications(List<MedicationEntity> rows) async {
    for (var row in rows) {
      await db.medicationsDao.insertOrUpdateMedication(MedicationsCompanion(
        id: drift.Value(row.id),
        name: drift.Value(row.name),
        dosage: drift.Value(row.dosage),
        purpose: drift.Value(row.purpose),
        toBeTakenAt: drift.Value(row.toBeTakenAt),
        taken: drift.Value(row.taken),
      ));
    }
  }

  @override
  Future<void> markMedicationTaken(
      String medicationId, String section, String effectiveDate) async {
    await db.medicationsDao.markMedicationTaken(medicationId);
    if (effectiveDate != _todayKey) return;

    await updateVitalJsonList('MED_SECTION_CACHE_${section}_$_todayKey',
        (list) {
      return list.map((m) {
        final entry = Map<String, dynamic>.from(m as Map);
        if (entry['id'] == medicationId) entry['taken'] = true;
        return entry;
      }).toList();
    }, byType: true);
  }

  @override
  Future<void> optimisticallyUpdateAdherence(String targetDate) async {
    double newRate = 0.0;

    final vitals = await db.vitalsDao.getAllVitals();
    final adherenceVital =
        vitals.where((v) => v.vitalType == 'ADHERENCE_CACHE').firstOrNull;
    if (adherenceVital != null) {
      final parsed = double.tryParse(adherenceVital.value) ?? 0.0;
      newRate = (parsed > 0 && parsed <= 1.0) ? parsed * 100 : parsed;
      newRate = (newRate + 5).clamp(0, 100);
      await cacheVital(
          id: 'adherence_cache_key',
          type: 'ADHERENCE_CACHE',
          name: 'Medication Adherence',
          value: newRate.toString(),
          unit: '%');
    }

    await updateVitalJsonMap('ADHERENCE_FULL_CACHE', (map) {
      map['rate'] = newRate;
      if (map['days'] != null) {
        final daysList = List<dynamic>.from(map['days']);
        for (var day in daysList) {
          if (day is Map &&
              day['takenAt']?.toString().startsWith(targetDate) == true) {
            day['taken'] = true;
          }
        }
        map['days'] = daysList;
      }
      return map;
    }, byType: true);
  }

  @override
  Future<void> cacheMedicationHistory(
      String medicationId, String date, MedicationHistoryEntity result) async {
    final logsJson = result.logs
        .map((l) => {
              'id': l.id,
              'taken': l.taken,
              'takenAt': l.takenAt.toIso8601String()
            })
        .toList();
    await cacheVital(
        id: 'med_history_${medicationId}_$date',
        type: 'MED_HISTORY_CACHE',
        name: 'History for $medicationId',
        value: jsonEncode({
          'medicationName': result.medicationName,
          'adherenceRate': result.adherenceRate,
          'logs': logsJson
        }));
  }

  @override
  Future<void> updateMedicationHistoryLog(
      String medicationId, String date, DateTime now) async {
    await updateVitalJsonMap('med_history_${medicationId}_$date', (map) {
      final logs = List<dynamic>.from(map['logs'] ?? []);
      logs.add({
        'id': const Uuid().v4(),
        'taken': true,
        'takenAt': now.toIso8601String()
      });
      map['logs'] = logs;
      map['adherenceRate'] =
          (((map['adherenceRate'] as num?)?.toDouble() ?? 0.0) + 5)
              .clamp(0, 100);
      return map;
    });
  }

  @override
  AsyncResponse<MedicationHistoryEntity> getCachedMedicationHistory(
      String medicationId, String date) async {
    try {
      final history = await readVitalCache<MedicationHistoryEntity>(
          'med_history_${medicationId}_$date', parseHistoryJson);
      if (history != null) return right(history);

      final localMeds = await db.medicationsDao.getAllMedications();
      final target = localMeds.where((m) => m.id == medicationId).firstOrNull;
      if (target != null) {
        return right(MedicationHistoryEntity(
            medicationName: target.name, adherenceRate: 0, logs: const []));
      }
      return left('Cache failure');
    } catch (e) {
      return left('Cache failure');
    }
  }

  @override
  AsyncResponse<MedicationDetailModel> getMedicationById(String id) async {
    try {
      final localMeds = await db.medicationsDao.getAllMedications();
      final target = localMeds.where((m) => m.id == id).firstOrNull;
      if (target == null) return left('Not found in cache');

      DosingScheduleModel? parseSchedule(String? jsonStr) {
        if (jsonStr == null || jsonStr == 'null' || jsonStr.isEmpty) {
          return null;
        }
        try {
          dynamic decoded = jsonDecode(jsonStr);
          if (decoded is String) decoded = jsonDecode(decoded);
          if (decoded is Map<String, dynamic>) {
            return DosingScheduleModel.fromJson(decoded);
          }
        } catch (_) {}
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
    } catch (_) {
      return left('Cache failure');
    }
  }
}
