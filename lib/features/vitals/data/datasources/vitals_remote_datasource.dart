import '../../../../core/api/api_client.dart';
import '../models/vital_history_model.dart';

/// The vital-reading endpoints of the API.
class VitalsRemoteDataSource {
  VitalsRemoteDataSource({required APIClient apiClient}) : _api = apiClient;

  final APIClient _api;
  static const _logs = '/api/v1/client/vital-histories/logs';

  /// The latest 100 readings, newest first.
  Future<List<VitalHistoryModel>> fetchVitalHistories() async {
    final response = await _api.get('$_logs?pageSize=100');
    return [
      for (final row in response['data']['rows'] as List)
        VitalHistoryModel.fromJson({
          ...row as Map<String, dynamic>,
          'value': '${row['value']}',
          // Older server rows have no grade.
          'severity': row['severity'] ?? 'normal',
        }),
    ];
  }

  /// Saves a reading and returns the server's id for it, if it sent one.
  ///
  /// [idempotencyKey] is the reading's local id, so a retry never saves twice.
  Future<String?> saveVitalReading(Map<String, dynamic> body,
      {required String idempotencyKey}) async {
    final response = await _api.post(_logs,
        data: body, options: APIClient.idempotent(idempotencyKey));
    final id = response is Map ? response['data'] : null;
    return id is String && id.isNotEmpty ? id : null;
  }
}
