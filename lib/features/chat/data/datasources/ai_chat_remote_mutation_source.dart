import 'dart:convert';
import '../../../../core/api/i_remote_mutation.dart';
import 'ai_chat_remote_datasource.dart';

class AiChatRemoteMutationSource implements IRemoteMutationSource {
  final AiChatRemoteDataSource _remoteDataSource;

  AiChatRemoteMutationSource(this._remoteDataSource);

  @override
  Future<String?> syncMutation({
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) async {
    final payload = jsonDecode(payloadJson);

    switch (action) {
      case 'sendMessage':
        final message = payload['message'] as String;
        final localChatId = payload['localChatId'] as String?;
        await _remoteDataSource.sendMessage(message, localChatId: localChatId);
        return null;
      case 'sendAudioMessage':
        final filePath = payload['filePath'] as String;
        final localChatId = payload['localChatId'] as String?;
        await _remoteDataSource.sendAudioMessage(filePath: filePath, localChatId: localChatId);
        return null;
      default:
        throw UnimplementedError('Unknown action $action for chat');
    }
  }
}
