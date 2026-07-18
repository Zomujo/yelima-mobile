import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/medications.dart';

part 'medications_dao.g.dart';

@DriftAccessor(tables: [Medications])
class MedicationsDao extends DatabaseAccessor<AppDatabase> with _$MedicationsDaoMixin {
  MedicationsDao(super.db);

  Stream<List<Medication>> watchAllMedications() {
    return select(medications).watch();
  }

  Future<List<Medication>> getAllMedications() {
    return select(medications).get();
  }

  Future<void> insertOrUpdateMedication(MedicationsCompanion medication) {
    return into(medications).insertOnConflictUpdate(medication);
  }

  Future<void> deleteMedication(String id) {
    return (delete(medications)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markMedicationTaken(String id) {
    return (update(medications)..where((t) => t.id.equals(id)))
        .write(const MedicationsCompanion(taken: Value(true)));
  }

  Future<void> markSynced(String id) {
    return (update(medications)..where((t) => t.id.equals(id)))
        .write(const MedicationsCompanion(syncStatus: Value('synced')));
  }

  /// Partial update for a row already known to exist. Unlike
  /// [insertOrUpdateMedication] (which goes through insertOnConflictUpdate
  /// and therefore requires every non-nullable, no-default column to be
  /// present, since Drift validates it as a possible INSERT), this issues a
  /// plain UPDATE and accepts a companion with only the fields being
  /// changed - e.g. backfilling just the schedule columns.
  Future<void> updateMedicationFields(String id, MedicationsCompanion fields) {
    return (update(medications)..where((t) => t.id.equals(id))).write(fields);
  }

  Future<void> clearMedications() {
    return delete(medications).go();
  }

  Future<void> updateMedicationId(String oldId, String newId) {
    return (update(medications)..where((t) => t.id.equals(oldId)))
        .write(MedicationsCompanion(id: Value(newId)));
  }
}
