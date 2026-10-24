import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/adherence_globals.dart';
import '../tables/adherence_global_days.dart';
import '../tables/medication_logs.dart';
import 'package:clock/clock.dart';

part 'adherence_dao.g.dart';

@DriftAccessor(tables: [AdherenceGlobals, AdherenceGlobalDays, MedicationLogs])
class AdherenceDao extends DatabaseAccessor<AppDatabase>
    with _$AdherenceDaoMixin {
  AdherenceDao(super.db);

  // Global Adherence
  Future<void> saveGlobalAdherence(
      String id, double rate, List<AdherenceGlobalDay> days) async {
    await transaction(() async {
      await into(adherenceGlobals).insert(
        AdherenceGlobal(id: id, rate: rate, updatedAt: clock.now()),
        mode: InsertMode.insertOrReplace,
      );
      await (delete(adherenceGlobalDays)..where((t) => t.type.equals(id))).go();
      await batch((batch) {
        batch.insertAll(adherenceGlobalDays, days,
            mode: InsertMode.insertOrReplace);
      });
    });
  }

  Future<AdherenceGlobal?> getGlobalAdherenceRate(String id) {
    return (select(adherenceGlobals)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<AdherenceGlobal?> watchGlobalAdherenceRate(String id) {
    return (select(adherenceGlobals)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<List<AdherenceGlobalDay>> getGlobalAdherenceDays() {
    // Return sorted by date
    return (select(adherenceGlobalDays)
          ..orderBy([(t) => OrderingTerm(expression: t.dateTakenStr)]))
        .get();
  }

  // Medication Logs
  Future<void> saveMedicationLogs(List<MedicationLog> logs) async {
    await batch((batch) {
      batch.insertAll(medicationLogs, logs, mode: InsertMode.insertOrReplace);
    });
  }

  /// Points dose logs at a medication's server id after an offline create syncs.
  Future<void> updateLogsMedicationId(String oldId, String newId) =>
      (update(medicationLogs)..where((t) => t.medicationId.equals(oldId)))
          .write(MedicationLogsCompanion(medicationId: Value(newId)));

  Future<List<MedicationLog>> getLogsForMedication(String medicationId) {
    return (select(medicationLogs)
          ..where((t) => t.medicationId.equals(medicationId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.takenAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  // Optimistic updates
  Future<void> markMedicationLogAsTakenOffline(
      String logId, String medicationId, DateTime date) async {
    // Find the log for this exact medication on this exact day
    final logs = await (select(medicationLogs)
          ..where((t) => t.medicationId.equals(medicationId)))
        .get();

    final existing = logs
        .where((l) =>
            l.takenAt.year == date.year &&
            l.takenAt.month == date.month &&
            l.takenAt.day == date.day)
        .firstOrNull;

    if (existing != null) {
      await update(medicationLogs).replace(existing.copyWith(taken: true));
    } else {
      await into(medicationLogs).insert(MedicationLog(
        id: logId,
        medicationId: medicationId,
        takenAt: date,
        taken: true,
      ));
    }
  }

  /// Counts one more dose taken on [dateStr] (yyyy-MM-dd) until the server's
  /// numbers arrive. The day is done once all its doses are; the rate is per dose.
  Future<void> markGlobalDayAsTakenOffline(String dateStr) async {
    final day = await (select(adherenceGlobalDays)
          ..where((t) => t.dateTakenStr.like('$dateStr%')))
        .getSingleOrNull();
    final scheduled = day?.scheduledDoses;
    if (day == null || scheduled == null) return;

    final taken = ((day.takenDoses ?? 0) + 1).clamp(0, scheduled);
    await update(adherenceGlobalDays).replace(day.copyWith(
      takenDoses: Value(taken),
      taken: taken >= scheduled ? const Value(true) : Value(day.taken),
    ));

    final week = await (select(adherenceGlobalDays)
          ..where((t) => t.type.equals(day.type)))
        .get();
    var takenSum = 0, scheduledSum = 0;
    for (final d in week) {
      takenSum += d.takenDoses ?? 0;
      scheduledSum += d.scheduledDoses ?? 0;
    }
    if (scheduledSum == 0) return;
    await (update(adherenceGlobals)..where((t) => t.id.equals(day.type))).write(
        AdherenceGlobalsCompanion(rate: Value(takenSum / scheduledSum * 100)));
  }

  Future<void> clearAllAdherenceData() async {
    await delete(adherenceGlobals).go();
    await delete(adherenceGlobalDays).go();
    await delete(medicationLogs).go();
  }
}
