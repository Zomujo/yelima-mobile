import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/i_remote_mutation.dart';

class HomeMetricsRemoteMutationSource implements IRemoteMutationSource {
  final APIClient _apiClient;

  HomeMetricsRemoteMutationSource(this._apiClient);

  @override
  Future<String?> syncMutation({
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) async {
    final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

    final options = Options(
      headers: {
        'Idempotency-Key': entityId,
        'If-Unmodified-Since': createdAt.toUtc().toIso8601String(),
      },
    );

    if (action == 'saveVitalReading') {
      await _apiClient.post(
        '/api/v1/client/vital-histories/logs',
        data: payload,
        options: options,
      );

      return entityId;
    }

    throw Exception('Unknown action: $action');
  }
}
