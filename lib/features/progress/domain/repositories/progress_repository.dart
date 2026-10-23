import '../../../../core/failures/app_failure.dart';
import '../entities/vital_trends.dart';

/// Blood pressure and sugar trends from the server, cached for offline viewing.
abstract class ProgressRepository {
  /// The blood pressure trend last saved on the phone for [range].
  AsyncResult<BPTrend> getCachedBPTrend(ChartDateRange range);

  /// The server's blood pressure trend, or the phone's copy when that fails.
  AsyncResult<BPTrend> getBPTrend(ChartDateRange range);

  /// The blood sugar trend last saved on the phone for [range].
  AsyncResult<VitalTrend> getCachedSugarTrend(ChartDateRange range);

  /// The server's blood sugar trend, or the phone's copy when that fails.
  AsyncResult<VitalTrend> getSugarTrend(ChartDateRange range);
}
