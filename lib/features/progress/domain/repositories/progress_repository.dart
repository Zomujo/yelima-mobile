import '../entities/vital_trends.dart';
import '../../../../core/utils/custom_types.dart';

abstract class ProgressRepository {
  AsyncResponse<BPTrend> getBPTrend({required ChartDateRange dateRange});
  AsyncResponse<BPTrend> getCachedBPTrend({required ChartDateRange dateRange});
  AsyncResponse<VitalTrend> getVitalTrend(
      {required String vitalType, required ChartDateRange dateRange});
  AsyncResponse<VitalTrend> getCachedVitalTrend(
      {required String vitalType, required ChartDateRange dateRange});
}
