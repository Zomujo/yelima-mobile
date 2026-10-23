import '../../../../core/failures/app_failure.dart';
import '../entities/ai_chat_message.dart';
import '../entities/paginated_chat_result.dart';

/// The AI chat history and sending, saved on the phone and synced when online.
abstract class AiChatRepository {
  /// One page of older history from the server.
  AsyncResult<PaginatedChatResult> fetchPaginatedConversations(
      {required int page});

  /// The history saved on the phone.
  AsyncResult<List<AiChatMessage>> loadConversations();

  /// Saves the history on the phone.
  AsyncResult<void> saveConversations(List<AiChatMessage> conversations);

  /// Removes a message from the phone only (a failed one about to be resent).
  AsyncResult<void> deleteLocalMessageOnly(String id);

  /// Deletes a message here and, once online, on the server.
  AsyncResult<void> deleteMessage(String id);

  /// Sends text; queues it when offline or when the send fails.
  AsyncResult<ChatReply> sendMessage(String message, {String? localChatId});

  /// Sends a voice note; queues it when offline or when the send fails.
  AsyncResult<ChatReply> sendAudioMessage(
      {required String filePath, String? localChatId});

  /// The bot's greeting for an empty chat.
  AsyncResult<AiChatMessage?> loadInitialMessage();

  /// Merges the server's latest history into the phone's, keeping unsent messages.
  AsyncResult<void> syncRemoteConversations();

  /// Emits after a queued chat message reached the server.
  Stream<void> get onSynced;

  /// A downloaded voice note for the first of [ids] that has one, or null.
  Future<String?> cachedAudioPath(List<String> ids);

  /// Downloads a voice note and returns where it was saved.
  AsyncResult<String> downloadAudio(String url, List<String> ids);
}
