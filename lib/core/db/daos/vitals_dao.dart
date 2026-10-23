import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/vital_histories.dart';

part 'vitals_dao.g.dart';

@DriftAccessor(tables: [VitalHistories])
class VitalsDao extends DatabaseAccessor<AppDatabase> with _$VitalsDaoMixin {
  VitalsDao(super.db);

  Future<List<VitalHistory>> getAllVitals() => select(vitalHistories).get();

  Stream<List<VitalHistory>> watchAllVitals() => select(vitalHistories).watch();

  Stream<List<VitalHistory>> watchVitalsByType(String type) =>
      (select(vitalHistories)..where((t) => t.vitalType.equals(type))).watch();

  Future<void> insertVitals(List<VitalHistoriesCompanion> vitals) async {
    await batch((batch) {
      batch.insertAll(vitalHistories, vitals, mode: InsertMode.insertOrReplace);
    });
  }

  /// Deletes cached readings except cache/trend rows, offline rows and [keepIds].
  Future<void> clearVitals({Set<String> keepIds = const {}}) {
    return (delete(vitalHistories)
          ..where((t) => t.vitalType.like('%${"CACHE"}%').not())
          ..where((t) => t.vitalType.like('%${"TREND"}%').not())
          ..where((t) => t.id.like('offline_%').not())
          ..where((t) => t.id.isNotIn(keepIds)))
        .go();
  }

  /// Renames a reading's id, e.g. from its local id to the server's after sync.
  Future<void> updateVitalId(String oldId, String newId) =>
      (update(vitalHistories)..where((t) => t.id.equals(oldId)))
          .write(VitalHistoriesCompanion(id: Value(newId)));

  Future<void> clearAllVitals() {
    return delete(vitalHistories).go();
  }
}
