import 'package:timezone/timezone.dart' as tz;

import '../../../../core/api/api_client.dart';
import '../../domain/entities/vital_trends.dart';

/// The vital trend endpoints of the API.
class ProgressRemoteDataSource {
  ProgressRemoteDataSource(this._api);

  final APIClient _api;
  static const _trends = '/api/v1/client/vital-histories/trends';

  /// The phone's time zone, so "today" and "this week" end where the user's do.
  static Map<String, String> _range(String dateRange) =>
      {'dateRange': dateRange, 'tz': tz.local.name};

  /// Blood pressure points for [dateRange] (`today`, `thisWeek`, `thisMonth`).
  Future<BPTrend> getBPTrend({required String dateRange}) async =>
      BPTrend.fromJson((await _api.get('$_trends/bp',
          queryParameters: _range(dateRange)))['data']);

  /// [vitalType] points for [dateRange].
  Future<VitalTrend> getVitalTrend(
          {required String vitalType, required String dateRange}) async =>
      VitalTrend.fromJson((await _api.get(_trends, queryParameters: {
        'vitalType': vitalType,
        ..._range(dateRange)
      }))['data']);
}
