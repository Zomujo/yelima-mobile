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

  Future<void> updateMedicationId(String oldId, String newId) async {
    final existing = await getMedicationById(newId);
    if (existing.isNotEmpty) {
      await deleteMedication(oldId);
    } else {
      await (update(medications)..where((tbl) => tbl.id.equals(oldId))).write(
        MedicationsCompanion(id: Value(newId)),
      );
    }
  }

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
