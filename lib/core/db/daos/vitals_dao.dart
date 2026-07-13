import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/vital_histories.dart';

part 'vitals_dao.g.dart';

@DriftAccessor(tables: [VitalHistories])
class VitalsDao extends DatabaseAccessor<AppDatabase> with _$VitalsDaoMixin {
  VitalsDao(super.db);

  Future<List<VitalHistory>> getAllVitals() => select(vitalHistories).get();
  
  Stream<List<VitalHistory>> watchAllVitals() => select(vitalHistories).watch();
  
  Future<void> insertVitals(List<VitalHistoriesCompanion> vitals) async {
    await batch((batch) {
      batch.insertAll(vitalHistories, vitals, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> clearVitals() {
    return (delete(vitalHistories)
          ..where((t) => t.vitalType.like('%CACHE%').not())
          ..where((t) => t.vitalType.like('%TREND%').not())
          ..where((t) => t.id.like('offline_%').not()))
        .go();
  }

  Future<void> clearAllVitals() {
    return delete(vitalHistories).go();
  }
}
