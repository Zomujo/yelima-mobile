import 'ai_chat_message.dart';

class PaginatedChatResult {
  final List<AiChatMessage> messages;
  final int totalPages;

  PaginatedChatResult({required this.messages, required this.totalPages});
}
