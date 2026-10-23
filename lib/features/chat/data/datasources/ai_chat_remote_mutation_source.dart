import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/api/i_remote_mutation.dart';
import '../../../../core/db/app_database.dart';
import '../../domain/entities/ai_chat_message.dart';
import 'ai_chat_remote_datasource.dart';
import 'package:drift/drift.dart' as drift;
import 'package:clock/clock.dart';

class AiChatRemoteMutationSource implements IRemoteMutationSource {
  final AiChatRemoteDataSource _remoteDataSource;
  final AppDatabase _db;

  AiChatRemoteMutationSource(this._remoteDataSource, this._db);

  /// Saves the bot reply locally and returns the server id of the user's message.
  Future<String?> _handleReply(
      Map<String, dynamic> response, String? localChatId) async {
    final botData = response['outResponse'] as Map<String, dynamic>?;
    if (botData == null) return null;

    List<String> suggestions = [];
    if (botData['suggestions'] != null) {
      suggestions = List<String>.from(botData['suggestions']);
    }

    final botMsg = AiChatConversationsCompanion.insert(
      id: botData['_id'] as String,
      sender: 'bot',
      type: 'text',
      value: botData['text'] as String,
      createdAt: clock.now(),
      status: MessageStatus.sent.name,
      suggestionsJson: drift.Value(jsonEncode(suggestions)),
      localChatId: drift.Value(localChatId),
    );

    await _db.aiChatDao.insertAiChats([botMsg]);
    return (response['inResponse'] as Map<String, dynamic>?)?['_id'] as String?;
  }

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
        final res = await _remoteDataSource.sendMessage(message,
            localChatId: localChatId);
        // The user message's server id lets MutationSyncManager remap our local id.
        return _handleReply(res, localChatId);

      case 'sendAudioMessage':
        String filePath = payload['filePath'] as String;
        final localChatId = payload['localChatId'] as String?;

        if (!filePath.startsWith('/')) {
          final directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$filePath';
        }

        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception(
              "Audio file not found at $filePath. Cannot sync mutation.");
        }

        final res = await _remoteDataSource.sendAudioMessage(
            filePath: filePath, localChatId: localChatId);
        return _handleReply(res, localChatId);

      default:
        throw UnimplementedError('Unknown action $action for chat');
    }
  }
}
