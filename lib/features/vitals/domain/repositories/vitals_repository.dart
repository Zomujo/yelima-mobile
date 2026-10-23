import 'package:yelima/core/utils/custom_types.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';

abstract class VitalsRepository {
  AsyncResponse<HomeMetricsEntity> getCachedHomeMetrics();
  AsyncResponse<HomeMetricsEntity> getHomeMetrics();
  AsyncResponse<void> saveVitalReading(VitalHistoryEntity entity);
  Stream<List<VitalHistoryEntity>> watchVitalHistories();
}
