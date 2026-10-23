import '../../../../core/api/api_client.dart';
import '../models/vital_history_model.dart';

abstract class HomeMetricsRemoteDataSource {
  Future<List<VitalHistoryModel>> fetchVitalHistories();
  Future<Map<String, dynamic>> fetchMedicationAdherence();
  Future<void> saveVitalReading(Map<String, dynamic> body);
}

class HomeMetricsRemoteDataSourceImpl implements HomeMetricsRemoteDataSource {
  final APIClient _apiClient;

  HomeMetricsRemoteDataSourceImpl({required APIClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<VitalHistoryModel>> fetchVitalHistories() async {
    final response = await _apiClient
        .get('/api/v1/client/vital-histories/logs?pageSize=100');
    final data = response['data'] as Map<String, dynamic>;
    final rows = data['rows'] as List;
    return rows.map((e) {
      final map = Map<String, dynamic>.from(e);
      if (map['value'] != null) {
        map['value'] = map['value'].toString();
      }
      // Provide a default severity if missing, as the backend didn't send it
      if (map['severity'] == null) {
        map['severity'] = 'normal';
      }
      return VitalHistoryModel.fromJson(map);
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> fetchMedicationAdherence() async {
    final response = await _apiClient
        .get('/api/v1/client/medication-adherence?showWeekdays=true');
    return response is Map ? Map<String, dynamic>.from(response) : {};
  }

  @override
  Future<void> saveVitalReading(Map<String, dynamic> body) async {
    await _apiClient.post(
      '/api/v1/client/vital-histories/logs',
      data: body,
    );
  }
}
