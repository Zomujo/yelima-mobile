import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/medications.dart';
import '../tables/preloaded_medications.dart';

part 'medications_dao.g.dart';

@DriftAccessor(tables: [Medications, PreloadedMedications])
class MedicationsDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationsDaoMixin {
  MedicationsDao(super.db);

  // Medications CRUD
  Future<List<Medication>> getAllMedications() => select(medications).get();

  Future<List<Medication>> getMedicationById(String id) {
    return (select(medications)..where((tbl) => tbl.id.equals(id))).get();
  }

  Stream<List<Medication>> watchMedicationsBySection(String section) {
    return (select(medications)..where((tbl) => tbl.section.equals(section)))
        .watch();
  }

  Stream<List<Medication>> watchAllMedications() {
    return select(medications).watch();
  }

  Future<void> insertMedication(Medication med) =>
      into(medications).insert(med, mode: InsertMode.insertOrReplace);

  Future<void> insertMedications(List<Medication> meds) async {
    await batch((batch) {
      batch.insertAll(medications, meds, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> updateMedication(Medication med) =>
      update(medications).replace(med);

  Future<void> deleteMedication(String id) =>
      (delete(medications)..where((tbl) => tbl.id.equals(id))).go();

  /// Deletes one section row of a medication, leaving its other sections.
  Future<void> deleteMedicationSection(String id, String section) =>
      (delete(medications)
            ..where((tbl) => tbl.id.equals(id) & tbl.section.equals(section)))
          .go();

  /// Deletes rows the old background list sync stored without a section; returns their ids.
  Future<List<String>> deleteUnknownSectionRows() => transaction(() async {
        final unknown = await (select(medications)
              ..where((tbl) => tbl.section.equals('UNKNOWN')))
            .get();
        await (delete(medications)
              ..where((tbl) => tbl.section.equals('UNKNOWN')))
            .go();
        return unknown.map((m) => m.id).toList();
      });

  /// Moves a medication from its local id to the server id.
  ///
  /// If a background fetch already stored server rows, those keep the server's
  /// state but take the local schedule and notes, which only the device has.
  Future<void> updateMedicationId(String oldId, String newId) =>
      transaction(() async {
        final server = {
          for (final m in await getMedicationById(newId)) m.section: m
        };
        for (final local in await getMedicationById(oldId)) {
          final existing = server[local.section];
          await insertMedication(existing == null
              ? local.copyWith(id: newId)
              : existing.copyWith(
                  morningJson: Value(local.morningJson),
                  afternoonJson: Value(local.afternoonJson),
                  eveningJson: Value(local.eveningJson),
                  notes: Value(local.notes),
                ));
        }
        await deleteMedication(oldId);
      });

  Future<void> clearMedications() => delete(medications).go();

  // Preloaded Medications Caching
  Future<void> insertPreloadedMedications(
      List<PreloadedMedication> meds) async {
    await batch((batch) {
      batch.insertAll(preloadedMedications, meds,
          mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<PreloadedMedication>> searchPreloadedMedications(String query) {
    if (query.isEmpty) return select(preloadedMedications).get();
    return (select(preloadedMedications)
          ..where((tbl) => tbl.name.like('%$query%')))
        .get();
  }

  Future<void> clearPreloadedMedications() => delete(preloadedMedications).go();
}
