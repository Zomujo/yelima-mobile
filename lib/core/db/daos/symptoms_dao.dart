import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/symptoms.dart';

part 'symptoms_dao.g.dart';

@DriftAccessor(tables: [Symptoms])
class SymptomsDao extends DatabaseAccessor<AppDatabase> with _$SymptomsDaoMixin {
  SymptomsDao(super.db);

  Future<List<Symptom>> getAllSymptoms() {
    return select(symptoms).get();
  }

  Stream<List<Symptom>> watchAllSymptoms() {
    return select(symptoms).watch();
  }

  Future<void> insertOrUpdateSymptom(SymptomsCompanion symptom) {
    return into(symptoms).insertOnConflictUpdate(symptom);
  }

  Future<void> deleteSymptomById(String id) {
    return (delete(symptoms)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearSymptoms() {
    return delete(symptoms).go();
  }
}
