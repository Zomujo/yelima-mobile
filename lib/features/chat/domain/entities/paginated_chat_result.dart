import 'ai_chat_message.dart';

/// One page of chat history from the server.
class PaginatedChatResult {
  const PaginatedChatResult({required this.messages, required this.totalPages});

  final List<AiChatMessage> messages;
  final int totalPages;
}

/// What sending a message returned: the user message's server id and the bot's answer.
/// No [bot] means the message was queued to send later.
class ChatReply {
  const ChatReply({this.userMessageId, this.bot});

  /// A message queued while offline or after a failed send.
  const ChatReply.queued() : this();

  final String? userMessageId;
  final AiChatMessage? bot;
}
