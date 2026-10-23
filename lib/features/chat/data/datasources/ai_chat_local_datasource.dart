import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/entities/ai_chat_message.dart';

/// The chat history and its queues in the local database.
class AiChatLocalDataSource {
  AiChatLocalDataSource(this._db);

  final AppDatabase _db;

  /// Every saved message; one still "sending" from before a restart counts as failed.
  Future<List<AiChatMessage>> getChats() async => [
        for (final e in await _db.aiChatDao.getAllAiChats())
          AiChatMessage(
            id: e.id,
            sender: e.sender,
            type: e.type == 'audio' ? MessageType.audio : MessageType.text,
            value: e.value,
            createdAt: e.createdAt,
            status: switch (MessageStatus.values
                .where((s) => s.name == e.status)
                .firstOrNull) {
              MessageStatus.sending => MessageStatus.failed,
              final s? => s,
              null => MessageStatus.sent,
            },
            suggestions: _strings(e.suggestionsJson),
            localChatId: e.localChatId,
            audioUrl: e.audioUrl,
          ),
      ];

  /// Saves (or replaces) [chats].
  Future<void> saveChats(List<AiChatMessage> chats) =>
      _db.aiChatDao.insertAiChats([
        for (final c in chats)
          AiChatConversationsCompanion.insert(
            id: c.id,
            sender: c.sender,
            type: c.type.name,
            value: c.value,
            createdAt: c.createdAt,
            status: c.status.name,
            suggestionsJson: Value(jsonEncode(c.suggestions)),
            localChatId: Value(c.localChatId),
            audioUrl: Value(c.audioUrl),
          ),
      ]);

  Future<void> clearChats() => _db.aiChatDao.clearAiChats();

  Future<void> deleteChat(String id) => _db.aiChatDao.deleteAiChat(id);

  /// Gives a message its server id.
  Future<void> updateMessageId(String oldId, String newId) =>
      _db.aiChatDao.updateMessageId(oldId, newId);

  /// Remembers to delete [id] on the server once online.
  Future<void> queueDeletion(String id) =>
      _db.aiChatDao.insertPendingDeletion(id, 'chat');

  /// Ids still waiting to be deleted on the server.
  Future<Set<String>> getPendingDeletions() async => {
        for (final d in await _db.aiChatDao.getPendingDeletions())
          if (d.source == 'chat') d.messageId
      };

  /// Queues a send to replay once online.
  Future<void> queueSend(
          {required String entityId,
          required String action,
          required Map<String, dynamic> payload}) =>
      _db.pendingMutationsDao.queueMutation(
          entityId: entityId,
          entityType: 'chat',
          action: action,
          payload: payload);

  static List<String> _strings(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      return List<String>.from(jsonDecode(json));
    } catch (_) {
      return const [];
    }
  }
}
