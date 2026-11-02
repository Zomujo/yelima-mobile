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

  /// Saves the weekly rate and merges [days] in by date. Days stay for two
  /// weeks, since the 7-day rate reaches back into last week.
  Future<void> saveGlobalAdherence(
      String id, double rate, List<AdherenceGlobalDay> days) async {
    final now = clock.now();
    final oldest = DateTime(now.year, now.month, now.day - 14);
    await transaction(() async {
      await into(adherenceGlobals).insert(
        AdherenceGlobal(id: id, rate: rate, updatedAt: now),
        mode: InsertMode.insertOrReplace,
      );
      await batch((batch) {
        batch.insertAll(adherenceGlobalDays, days,
            mode: InsertMode.insertOrReplace);
      });
      await (delete(adherenceGlobalDays)
            ..where((t) =>
                t.type.equals(id) &
                t.dateTakenStr.isSmallerThanValue(oldest.toIso8601String())))
          .go();
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

  /// Replaces a medication's stored days in [month] with [logs].
  ///
  /// By day, not by id: the server gives some days a new id on every call.
  /// Where the server's rate for one medication's month is kept.
  static String monthRateId(String medicationId, DateTime month) =>
      'medication:$medicationId:${month.year}-${month.month}';

  /// The server's rate for [medicationId] in [month], if it was saved here.
  Future<int?> getMonthRate(String medicationId, DateTime month) async =>
      (await getGlobalAdherenceRate(monthRateId(medicationId, month)))
          ?.rate
          .round();

  Future<void> replaceMonthLogs(
      String medicationId, DateTime month, List<MedicationLog> logs,
      {int? rate}) async {
    final start = DateTime.utc(month.year, month.month);
    final end = DateTime.utc(month.year, month.month + 1);
    await transaction(() async {
      await (delete(medicationLogs)
            ..where((t) =>
                t.medicationId.equals(medicationId) &
                t.takenAt.isBiggerOrEqualValue(start) &
                t.takenAt.isSmallerThanValue(end)))
          .go();
      await batch((batch) => batch.insertAll(medicationLogs, logs,
          mode: InsertMode.insertOrReplace));
      if (rate != null) {
        await into(adherenceGlobals).insert(
            AdherenceGlobal(
                id: monthRateId(medicationId, month),
                rate: rate.toDouble(),
                updatedAt: clock.now()),
            mode: InsertMode.insertOrReplace);
      }
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

  /// Marks the day taken here. With [estimateRate] (offline) the saved server
  /// rate is dropped for the phone's own count; online the server's new one follows.
  Future<void> markMedicationLogAsTakenOffline(
      String logId, String medicationId, DateTime date,
      {bool estimateRate = true}) async {
    if (estimateRate) {
      await (delete(adherenceGlobals)
            ..where((t) => t.id.equals(monthRateId(medicationId, date))))
          .go();
    }
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

  Future<void> clearAllAdherenceData() async {
    await delete(adherenceGlobals).go();
    await delete(adherenceGlobalDays).go();
    await delete(medicationLogs).go();
  }
}
