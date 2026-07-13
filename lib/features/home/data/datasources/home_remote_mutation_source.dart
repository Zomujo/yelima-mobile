import 'dart:convert';
import '../../../../core/api/i_remote_mutation.dart';
import 'home_metrics_remote_datasource.dart';

class HomeRemoteMutationSource implements IRemoteMutationSource {
  final HomeMetricsRemoteDataSource _remoteDataSource;

  HomeRemoteMutationSource(this._remoteDataSource);

  @override
  Future<String?> syncMutation({
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) async {
    final payload = jsonDecode(payloadJson);

    switch (action) {
      case 'saveVitalReading':
        await _remoteDataSource.saveVitalReading(payload);
        return null;
      default:
        throw UnimplementedError('Unknown action $action for vital_history');
    }
  }
}
