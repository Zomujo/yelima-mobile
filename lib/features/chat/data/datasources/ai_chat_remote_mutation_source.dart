import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../core/api/i_remote_mutation.dart';
import '../../../../core/db/app_database.dart';
import '../models/ai_chat_response.dart';
import 'ai_chat_local_datasource.dart';
import 'ai_chat_remote_datasource.dart';

/// Replays queued chat messages, saving the bot's answers on the phone.
class AiChatRemoteMutationSource implements IRemoteMutationSource {
  AiChatRemoteMutationSource(this._remote, AppDatabase db)
      : _local = AiChatLocalDataSource(db);

  final AiChatRemoteDataSource _remote;
  final AiChatLocalDataSource _local;

  @override
  Future<String?> syncMutation({
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) async {
    final payload = jsonDecode(payloadJson);
    final localChatId = payload['localChatId'] as String?;
    final response = switch (action) {
      'sendMessage' => await _remote.sendMessage(payload['message'] as String,
          localChatId: localChatId),
      'sendAudioMessage' => await _remote.sendAudioMessage(
          filePath: await _audioFile(payload['filePath'] as String),
          localChatId: localChatId),
      _ => throw UnimplementedError('Unknown action $action for chat'),
    };
    final reply = chatReplyFromJson(response, localChatId);
    if (reply.bot != null) await _local.saveChats([reply.bot!]);
    // The user message's server id lets the sync manager remap the local id.
    return reply.userMessageId;
  }

  /// Queued voice notes store only the file name; the app folder can move.
  static Future<String> _audioFile(String path) async {
    final full = path.startsWith('/')
        ? path
        : '${(await getApplicationDocumentsDirectory()).path}/$path';
    if (!await File(full).exists()) {
      throw Exception('Audio file not found at $full. Cannot sync mutation.');
    }
    return full;
  }

  @override
  Future<void> remapLocalId(String oldId, String newId) =>
      _local.updateMessageId(oldId, newId);
}
