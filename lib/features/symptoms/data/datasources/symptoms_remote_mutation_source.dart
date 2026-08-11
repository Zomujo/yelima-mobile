import 'dart:convert';
import '../../../../core/api/i_remote_mutation.dart';
import 'symptoms_remote_data_source.dart';

class SymptomsRemoteMutationSource implements IRemoteMutationSource {
  final SymptomsRemoteDataSource _remoteDataSource;

  SymptomsRemoteMutationSource(this._remoteDataSource);

  @override
  Future<String?> syncMutation({
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) async {
    final payload = jsonDecode(payloadJson);

    switch (action) {
      case 'create':
        final description = payload['description'] as String;
        final res = await _remoteDataSource.createSymptom(description);
        return res; 

      case 'update':
        final description = payload['description'] as String;
        await _remoteDataSource.updateSymptom(entityId, description);
        return null;

      case 'delete':
        await _remoteDataSource.deleteSymptom(entityId);
        return null;

      default:
        throw UnimplementedError('Unknown action $action for symptom');
    }
  }
}
