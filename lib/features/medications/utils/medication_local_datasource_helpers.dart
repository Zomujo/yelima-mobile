import 'dart:convert';
import 'dart:isolate';
import 'package:drift/drift.dart' as drift;

import '../../../core/db/app_database.dart';
import '../domain/entities/medication_entity.dart';

mixin MedicationLocalDataSourceHelpers {
  AppDatabase get db;

  Future<void> cacheVital({
    required String id,
    required String type,
    required String name,
    required String value,
    String unit = 'json',
  }) async {
    await db.vitalsDao.insertVitals([
      VitalHistoriesCompanion(
        id: drift.Value(id),
        vitalType: drift.Value(type),
        vitalName: drift.Value(name),
        value: drift.Value(value),
        unit: drift.Value(unit),
        severity: const drift.Value('normal'),
        recordedAt: drift.Value(DateTime.now()),
      )
    ]);
  }

  Future<T?> readVitalCache<T>(
    String idOrType,
    T Function(String) parser, {
    bool byType = false,
  }) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      final vital = vitals
          .where((v) => byType ? v.vitalType == idOrType : v.id == idOrType)
          .firstOrNull;
      if (vital != null) {
        return await Isolate.run(() => parser(vital.value));
      }
    } catch (_) {}
    return null;
  }

  Future<void> updateVitalJsonMap(String idOrType,
      Map<String, dynamic> Function(Map<String, dynamic>) updater,
      {bool byType = false}) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      final vital = vitals
          .where((v) => byType ? v.vitalType == idOrType : v.id == idOrType)
          .firstOrNull;
      if (vital != null) {
        final decoded = jsonDecode(vital.value);
        if (decoded is Map<String, dynamic>) {
          await cacheVital(
              id: vital.id,
              type: vital.vitalType,
              name: vital.vitalName,
              value: jsonEncode(updater(decoded)));
        }
      }
    } catch (_) {}
  }

  Future<void> updateVitalJsonList(
      String idOrType, List<dynamic> Function(List<dynamic>) updater,
      {bool byType = false}) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      final vital = vitals
          .where((v) => byType ? v.vitalType == idOrType : v.id == idOrType)
          .firstOrNull;
      if (vital != null) {
        final decoded = jsonDecode(vital.value);
        if (decoded is List<dynamic>) {
          await cacheVital(
              id: vital.id,
              type: vital.vitalType,
              name: vital.vitalName,
              value: jsonEncode(updater(decoded)));
        }
      }
    } catch (_) {}
  }

  MedicationEntity mapToEntity(Medication m) {
    return MedicationEntity(
      id: m.id,
      name: m.name,
      dosage: m.dosage,
      purpose: m.purpose,
      toBeTakenAt: m.toBeTakenAt ?? DateTime.now(),
      taken: m.taken,
    );
  }

  DateTime? parseScheduleTime(String? scheduleJson) {
    if (scheduleJson == null) return null;
    try {
      final map = jsonDecode(scheduleJson);
      final timeModel = map['time'];
      var hour = timeModel['hour'] as int;
      final min = timeModel['minutes'] as int;
      final des = timeModel['timeDesignators'] as String;

      if (des == 'PM' && hour < 12) hour += 12;
      if (des == 'AM' && hour == 12) hour = 0;

      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, min);
    } catch (_) {
      return null;
    }
  }
}
