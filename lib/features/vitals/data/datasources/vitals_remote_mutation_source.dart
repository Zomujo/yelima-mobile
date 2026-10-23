import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yelima/core/api/api_client.dart';
import 'package:yelima/core/api/i_remote_mutation.dart';
import 'package:yelima/core/db/app_database.dart';

class VitalsRemoteMutationSource implements IRemoteMutationSource {
  final APIClient _apiClient;
  final AppDatabase _db;

  VitalsRemoteMutationSource(this._apiClient, this._db);

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
      final res = await _apiClient.post(
        '/api/v1/client/vital-histories/logs',
        data: payload,
        options: options,
      );

      // The server replies with the new reading's id, so the local row can take it.
      final serverId = res is Map ? res['data'] : null;
      return serverId is String && serverId.isNotEmpty ? serverId : entityId;
    }

    throw Exception('Unknown action: $action');
  }

  @override
  Future<void> remapLocalId(String oldId, String newId) =>
      _db.vitalsDao.updateVitalId(oldId, newId);
}
