import '../../../../core/db/app_database.dart';
import '../models/vital_history_model.dart';

abstract class HomeMetricsLocalDataSource {
  Future<List<VitalHistoryModel>> getCachedVitalHistories();
  Future<void> cacheVitalHistories(List<VitalHistoryModel> vitals);
  Future<void> appendVitalHistory(VitalHistoryModel vital);
  Future<double?> getCachedAdherence();
  Future<void> cacheAdherence(double adherence);
  Future<void> clearCachedAdherence();
}

class HomeMetricsLocalDataSourceImpl implements HomeMetricsLocalDataSource {
  final AppDatabase _database;

  HomeMetricsLocalDataSourceImpl({required AppDatabase database})
      : _database = database;

  @override
  Future<List<VitalHistoryModel>> getCachedVitalHistories() async {
    final vitals = await _database.vitalsDao.getAllVitals();
    // Exclude cache and trend rows to retrieve only actual vital readings.
    final realVitals = vitals.where((v) =>
        !v.vitalType.contains('CACHE') && !v.vitalType.contains('TREND'));
    return realVitals.map((v) => VitalHistoryModel.fromDrift(v)).toList();
  }

  @override
  Future<void> cacheVitalHistories(List<VitalHistoryModel> vitals) async {
    await _database.vitalsDao.clearVitals();
    final companions = vitals.map((v) => v.toDrift()).toList();
    await _database.vitalsDao.insertVitals(companions);
  }

  @override
  Future<void> appendVitalHistory(VitalHistoryModel vital) async {
    await _database.vitalsDao.insertVitals([vital.toDrift()]);
  }

  // Retrieves adherence cached specifically for the Home feature.
  @override
  Future<double?> getCachedAdherence() async {
    final vitals = await _database.vitalsDao.getAllVitals();
    final adherenceVital =
        vitals.where((v) => v.vitalType == 'HOME_ADHERENCE_CACHE').firstOrNull;
    if (adherenceVital != null) {
      return double.tryParse(adherenceVital.value);
    }
    return null;
  }

  @override
  Future<void> cacheAdherence(double adherence) async {
    final adherenceModel = VitalHistoryModel(
      id: 'home_adherence_cache_key',
      vitalType: 'HOME_ADHERENCE_CACHE',
      vitalName: 'Medication Adherence',
      value: adherence.toString(),
      unit: 'fraction',
      severity: 'normal',
      recordedAt: DateTime.now(),
    );
    await _database.vitalsDao.insertVitals([adherenceModel.toDrift()]);
  }

  @override
  Future<void> clearCachedAdherence() async {
    await (_database.delete(_database.vitalHistories)
          ..where((t) => t.vitalType.equals('HOME_ADHERENCE_CACHE')))
        .go();
  }
}
