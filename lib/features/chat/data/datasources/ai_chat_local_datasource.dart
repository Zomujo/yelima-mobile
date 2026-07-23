import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../../domain/entities/ai_chat_message.dart';

abstract class AiChatLocalDataSource {
  Future<List<AiChatMessage>> getChats();
  Future<void> saveChats(List<AiChatMessage> chats);
  Future<void> clearChats();
  Future<void> deleteChat(String id);
  Future<void> queueDeletion(String id);
  Future<List<String>> getPendingDeletions();
  Future<void> queueOfflineMessageMutation({
    required String entityId,
    required String action,
    required Map<String, dynamic> payload,
  });
}

class AiChatLocalDataSourceImpl implements AiChatLocalDataSource {
  final AppDatabase _db;

  AiChatLocalDataSourceImpl(this._db);

  @override
  Future<List<AiChatMessage>> getChats() async {
    final conversations = await _db.aiChatDao.getAllAiChats();
    return conversations.map((e) {
      List<String> suggestions = [];
      if (e.suggestionsJson != null && e.suggestionsJson!.isNotEmpty) {
        try {
          suggestions = List<String>.from(jsonDecode(e.suggestionsJson!));
        } catch (_) {}
      }
      var mappedStatus = MessageStatus.values.firstWhere((s) => s.name == e.status, orElse: () => MessageStatus.sent);
      // Edge Case 3: If status was 'sending' when the app restarted, it's actually 'failed'
      if (mappedStatus == MessageStatus.sending) {
        mappedStatus = MessageStatus.failed;
      }
      return AiChatMessage(
        id: e.id,
        sender: e.sender,
        type: e.type == 'audio' ? MessageType.audio : MessageType.text,
        value: e.value,
        createdAt: e.createdAt,
        status: mappedStatus,
        suggestions: suggestions,
        localChatId: e.localChatId,
        audioUrl: e.audioUrl,
      );
    }).toList();
  }

  @override
  Future<void> saveChats(List<AiChatMessage> chats) async {
    final companions = chats.map((chat) {
      return AiChatConversationsCompanion.insert(
        id: chat.id,
        sender: chat.sender,
        type: chat.type.name,
        value: chat.value,
        createdAt: chat.createdAt,
        status: chat.status.name,
        suggestionsJson: Value(jsonEncode(chat.suggestions)),
        localChatId: Value(chat.localChatId),
        audioUrl: Value(chat.audioUrl),
      );
    }).toList();

    await _db.aiChatDao.insertAiChats(companions);
  }

  @override
  Future<void> clearChats() async {
    await _db.aiChatDao.clearAiChats();
  }

  @override
  Future<void> deleteChat(String id) async {
    await _db.aiChatDao.deleteAiChat(id);
  }

  @override
  Future<void> queueDeletion(String id) async {
    await _db.aiChatDao.insertPendingDeletion(id, 'chat');
  }

  @override
  Future<List<String>> getPendingDeletions() async {
    final deletions = await _db.aiChatDao.getPendingDeletions();
    return deletions.where((d) => d.source == 'chat').map((d) => d.messageId).toList();
  }

  @override
  Future<void> queueOfflineMessageMutation({
    required String entityId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    await _db.pendingMutationsDao.queueMutation(
      entityId: entityId,
      entityType: 'chat',
      action: action,
      payload: payload,
    );
  }
}
