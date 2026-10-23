import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_message.freezed.dart';
part 'ai_chat_message.g.dart';

/// A chat message is typed text or a voice note.
enum MessageType { text, audio }

/// Where a user message is: on its way, delivered, or failed to send.
enum MessageStatus { sending, sent, failed }

/// One message in the AI chat, from the user or the bot.
@freezed
abstract class AiChatMessage with _$AiChatMessage {
  // ignore: unused_element
  const AiChatMessage._();

  const factory AiChatMessage({
    required String id,

    /// 'bot' or 'user'.
    required String sender,
    required MessageType type,
    required String value,
    required DateTime createdAt,
    @Default(MessageStatus.sent) MessageStatus status,
    @Default([]) List<String> suggestions,
    String? localChatId,
    String? audioUrl,
  }) = _AiChatMessage;

  factory AiChatMessage.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageFromJson(json);
}
