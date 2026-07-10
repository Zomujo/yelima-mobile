import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_message.freezed.dart';
part 'ai_chat_message.g.dart';

enum MessageType { text, audio }

enum MessageStatus { sending, sent, failed }

@freezed
abstract class AiChatMessage with _$AiChatMessage {
  // ignore: unused_element
  const AiChatMessage._();

  const factory AiChatMessage({
    required String id,
    required String sender, // 'bot' or 'user'
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
