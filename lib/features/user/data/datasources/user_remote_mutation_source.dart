import 'dart:convert';
import '../../../../core/api/i_remote_mutation.dart';
import 'user_remote_data_source.dart';

/// Replays queued offline profile edits to the server.
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
    switch (action) {
      case 'updateUserProfile':
        await _remoteDataSource.updateUserProfile(
            entityId, jsonDecode(payloadJson) as Map<String, dynamic>);
        return null;
      case 'updatePatient':
        await _remoteDataSource
            .updatePatient(jsonDecode(payloadJson) as Map<String, dynamic>);
        return null;
      default:
        throw UnimplementedError('Unknown action $action for user_profile');
    }
  }

  /// The user's id is their Firebase uid, which never changes.
  @override
  Future<void> remapLocalId(String oldId, String newId) async {}
}
