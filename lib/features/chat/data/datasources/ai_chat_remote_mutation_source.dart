import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/api/i_remote_mutation.dart';
import '../../../../core/db/app_database.dart';
import '../../domain/entities/ai_chat_message.dart';
import 'ai_chat_remote_datasource.dart';
import 'package:drift/drift.dart' as drift;

class AiChatRemoteMutationSource implements IRemoteMutationSource {
  final AiChatRemoteDataSource _remoteDataSource;
  final AppDatabase _db;

  AiChatRemoteMutationSource(this._remoteDataSource, this._db);

  Future<void> _handleBotReply(Map<String, dynamic> response, String? localChatId) async {
    if (response['suggestions'] != null) {}
    final botData = response;
    
    List<String> suggestions = [];
    if (botData['suggestions'] != null) {
      suggestions = List<String>.from(botData['suggestions']);
    }

    final botMsg = AiChatConversationsCompanion.insert(
      id: botData['_id'] as String,
      sender: 'bot',
      type: 'text',
      value: botData['text'] as String,
      createdAt: DateTime.now(),
      status: MessageStatus.sent.name,
      suggestionsJson: drift.Value(jsonEncode(suggestions)),
      localChatId: drift.Value(localChatId),
    );

    await _db.aiChatDao.insertAiChats([botMsg]);
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
        final res = await _remoteDataSource.sendMessage(message, localChatId: localChatId);
        await _handleBotReply(res, localChatId);
        // We return the actual _id so MutationSyncManager can remap our localChatId
        return res['_id'] as String?;
        
      case 'sendAudioMessage':
        String filePath = payload['filePath'] as String;
        final localChatId = payload['localChatId'] as String?;
        
        if (!filePath.startsWith('/')) {
          final directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$filePath';
        }

        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception("Audio file not found at $filePath. Cannot sync mutation.");
        }

        final res = await _remoteDataSource.sendAudioMessage(filePath: filePath, localChatId: localChatId);
        await _handleBotReply(res, localChatId);
        return res['_id'] as String?;
        
      default:
        throw UnimplementedError('Unknown action $action for chat');
    }
  }
}
