import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/adherence_globals.dart';
import '../tables/adherence_global_days.dart';
import '../tables/medication_logs.dart';

part 'adherence_dao.g.dart';

@DriftAccessor(tables: [AdherenceGlobals, AdherenceGlobalDays, MedicationLogs])
class AdherenceDao extends DatabaseAccessor<AppDatabase> with _$AdherenceDaoMixin {
  AdherenceDao(super.db);

  // Global Adherence
  Future<void> saveGlobalAdherence(String id, double rate, List<AdherenceGlobalDay> days) async {
    await batch((batch) {
      batch.insert(
        adherenceGlobals,
        AdherenceGlobal(id: id, rate: rate, updatedAt: DateTime.now()),
        mode: InsertMode.insertOrReplace,
      );
      batch.insertAll(adherenceGlobalDays, days, mode: InsertMode.insertOrReplace);
    });
  }

  Future<AdherenceGlobal?> getGlobalAdherenceRate(String id) {
    return (select(adherenceGlobals)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<AdherenceGlobal?> watchGlobalAdherenceRate(String id) {
    return (select(adherenceGlobals)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<List<AdherenceGlobalDay>> getGlobalAdherenceDays() {
    // Return sorted by date
    return (select(adherenceGlobalDays)..orderBy([(t) => OrderingTerm(expression: t.dateTakenStr)])).get();
  }

  // Medication Logs
  Future<void> saveMedicationLogs(List<MedicationLog> logs) async {
    await batch((batch) {
      batch.insertAll(medicationLogs, logs, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<MedicationLog>> getLogsForMedication(String medicationId) {
    return (select(medicationLogs)
          ..where((t) => t.medicationId.equals(medicationId))
          ..orderBy([(t) => OrderingTerm(expression: t.takenAt, mode: OrderingMode.desc)]))
        .get();
  }

  // Optimistic updates
  Future<void> markMedicationLogAsTakenOffline(String logId, String medicationId, DateTime date) async {
    // Find the log for this exact medication on this exact day
    final logs = await (select(medicationLogs)
          ..where((t) => t.medicationId.equals(medicationId)))
        .get();

    final existing = logs.where((l) =>
        l.takenAt.year == date.year &&
        l.takenAt.month == date.month &&
        l.takenAt.day == date.day).firstOrNull;

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

  Future<void> markGlobalDayAsTakenOffline(String dateStr) async {
    // Match by prefix since dateStr is 'YYYY-MM-DD' and DB has 'YYYY-MM-DDT...'
    final existing = await (select(adherenceGlobalDays)
          ..where((t) => t.dateTakenStr.like('$dateStr%')))
        .getSingleOrNull();
        
    if (existing != null) {
      await update(adherenceGlobalDays)
          .replace(existing.copyWith(taken: const Value(true)));

      // Recalculate and update the rate optimistically
      final allDays = await (select(adherenceGlobalDays)
            ..where((t) => t.type.equals(existing.type)))
          .get();

      final total = allDays.length;
      final taken = allDays.where((d) => d.taken == true).length;
      final newRate = total > 0 ? ((taken / total) * 100).toDouble() : 0.0;

      final globals = await (select(adherenceGlobals)
            ..where((t) => t.id.equals(existing.type)))
          .getSingleOrNull();

      if (globals != null) {
        await update(adherenceGlobals)
            .replace(globals.copyWith(rate: newRate));
      }
    }
  }

  Future<void> clearAllAdherenceData() async {
    await delete(adherenceGlobals).go();
    await delete(adherenceGlobalDays).go();
    await delete(medicationLogs).go();
  }
}
