import '../../../../core/utils/custom_types.dart';
import '../entities/ai_chat_message.dart';
import '../entities/paginated_chat_result.dart';

abstract class AiChatRepository {
  AsyncResponse<PaginatedChatResult> fetchPaginatedConversations(
      {required int page});
  AsyncResponse<List<AiChatMessage>> loadConversations();
  AsyncResponse<void> saveConversations(List<AiChatMessage> conversations);
  AsyncResponse<void> clearConversations();
  AsyncResponse<void> deleteLocalMessageOnly(String id);
  AsyncResponse<void> deleteMessage(String id);
  AsyncResponse<Map<String, dynamic>> sendMessage(String message,
      {String? localChatId});
  AsyncResponse<Map<String, dynamic>> sendAudioMessage(
      {required String filePath, String? localChatId});
  AsyncResponse<AiChatMessage?> loadInitialMessage();
  AsyncResponse<void> syncRemoteConversations();
}
