import 'dart:convert';
import '../../../../core/api/i_remote_mutation.dart';
import 'user_remote_data_source.dart';

class UserRemoteMutationSource implements IRemoteMutationSource {
  final UserRemoteDataSource _remoteDataSource;

  UserRemoteMutationSource(this._remoteDataSource);

  @override
  Future<String?> syncMutation({
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) async {
    final payload = jsonDecode(payloadJson);

    switch (action) {
      case 'updateUserProfile':
        await _remoteDataSource.updateUserProfile(entityId, payload);
        return null; 
      default:
        throw UnimplementedError('Unknown action $action for user_profile');
    }
  }
}
