import '../../../../core/utils/custom_types.dart';
import '../entities/vital_history_entity.dart';

abstract class HomeMetricsRepository {
  AsyncResponse<HomeMetricsEntity> getCachedHomeMetrics();
  AsyncResponse<HomeMetricsEntity> getHomeMetrics();
  AsyncResponse<void> saveVitalReading(VitalHistoryEntity entity);
}
