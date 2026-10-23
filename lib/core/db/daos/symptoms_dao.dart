import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/symptoms.dart';

part 'symptoms_dao.g.dart';

@DriftAccessor(tables: [Symptoms])
class SymptomsDao extends DatabaseAccessor<AppDatabase>
    with _$SymptomsDaoMixin {
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

  /// Deletes cached symptoms except [keepIds] (e.g. ones still waiting to sync).
  Future<void> clearSymptoms({Set<String> keepIds = const {}}) {
    return (delete(symptoms)..where((t) => t.id.isNotIn(keepIds))).go();
  }

  /// Renames a symptom from its local id to the server's after sync.
  Future<void> updateSymptomId(String oldId, String newId) =>
      (update(symptoms)..where((t) => t.id.equals(oldId)))
          .write(SymptomsCompanion(id: Value(newId)));
}
