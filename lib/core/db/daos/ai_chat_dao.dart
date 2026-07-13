import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/ai_chat_conversations.dart';
import '../tables/pending_deletions.dart';

part 'ai_chat_dao.g.dart';

@DriftAccessor(tables: [AiChatConversations, PendingDeletions])
class AiChatDao extends DatabaseAccessor<AppDatabase> with _$AiChatDaoMixin {
  AiChatDao(super.db);

  // Ai Chat Queries
  Future<List<AiChatConversation>> getAllAiChats() =>
      (select(aiChatConversations)
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
            ]))
          .get();
          
  Future<void> insertAiChats(List<AiChatConversationsCompanion> chats) async {
    await batch((batch) {
      batch.insertAll(aiChatConversations, chats,
          mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> deleteAiChat(String id) =>
      (delete(aiChatConversations)..where((t) => t.id.equals(id))).go();
      
  Future<void> clearAiChats() => delete(aiChatConversations).go();

  Future<void> updateMessageId(String oldId, String newId) {
    return (update(aiChatConversations)..where((t) => t.id.equals(oldId)))
        .write(AiChatConversationsCompanion(id: Value(newId)));
  }

  // Pending Deletions Queries
  Future<List<PendingDeletion>> getPendingDeletions() => select(pendingDeletions).get();
  
  Future<void> insertPendingDeletion(String messageId, String source) async {
    await into(pendingDeletions).insert(
      PendingDeletionsCompanion.insert(messageId: messageId, source: source),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removePendingDeletion(String messageId, String source) async {
    await (delete(pendingDeletions)
          ..where((t) => t.messageId.equals(messageId))
          ..where((t) => t.source.equals(source)))
        .go();
  }

  Future<void> clearPendingDeletions() => delete(pendingDeletions).go();
}
