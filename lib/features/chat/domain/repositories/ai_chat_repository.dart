import '../../../../core/utils/custom_types.dart';
import '../entities/ai_chat_message.dart';
import '../../data/repositories/ai_chat_repository_impl.dart' show PaginatedChatResult;

abstract class AiChatRepository {
  AsyncResponse<PaginatedChatResult> fetchPaginatedConversations({required int page});
  AsyncResponse<List<AiChatMessage>> loadConversations();
  AsyncResponse<void> saveConversations(List<AiChatMessage> conversations);
  AsyncResponse<void> clearConversations();
  AsyncResponse<void> deleteLocalMessageOnly(String id);
  AsyncResponse<void> deleteMessage(String id);
  AsyncResponse<Map<String, dynamic>> sendMessage(String message, {String? localChatId});
  AsyncResponse<Map<String, dynamic>> sendAudioMessage({required String filePath, String? localChatId});
  AsyncResponse<AiChatMessage?> loadInitialMessage();
  AsyncResponse<void> syncRemoteConversations();
}
