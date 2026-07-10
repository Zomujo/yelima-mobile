import '../../../../core/api/api_client.dart';
import '../../domain/entities/vital_trends.dart';

abstract class ProgressRemoteDataSource {
  Future<BPTrend> getBPTrend({required String dateRange});
  Future<VitalTrend> getVitalTrend({required String vitalType, required String dateRange});
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  final APIClient _apiClient;

  ProgressRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BPTrend> getBPTrend({required String dateRange}) async {
    final response = await _apiClient.get('/api/v1/client/vital-histories/trends/bp', queryParameters: {
      'dateRange': dateRange,
    });
    return BPTrend.fromJson(response['data']);
  }

  @override
  Future<VitalTrend> getVitalTrend({required String vitalType, required String dateRange}) async {
    final response = await _apiClient.get('/api/v1/client/vital-histories/trends', queryParameters: {
      'vitalType': vitalType,
      'dateRange': dateRange,
    });
    return VitalTrend.fromJson(response['data']);
  }
}
