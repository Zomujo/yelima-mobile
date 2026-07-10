import '../entities/vital_trends.dart';
import '../../../../core/utils/custom_types.dart';

abstract class ProgressRepository {
  AsyncResponse<BPTrend> getBPTrend({required String dateRange});
  AsyncResponse<BPTrend> getCachedBPTrend({required String dateRange});
  AsyncResponse<VitalTrend> getVitalTrend(
      {required String vitalType, required String dateRange});
  AsyncResponse<VitalTrend> getCachedVitalTrend(
      {required String vitalType, required String dateRange});
}
