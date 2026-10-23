import 'package:clock/clock.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/ai_chat_message.dart';
import '../../domain/entities/paginated_chat_result.dart';

part 'ai_chat_response.freezed.dart';
part 'ai_chat_response.g.dart';

/// The chat history response.
@freezed
abstract class AiChatResponse with _$AiChatResponse {
  // ignore: unused_element
  const AiChatResponse._();

  const factory AiChatResponse({
    required AiChatData data,
  }) = _AiChatResponse;

  factory AiChatResponse.fromJson(Map<String, dynamic> json) =>
      _$AiChatResponseFromJson(json);
}

/// One page of history.
@freezed
abstract class AiChatData with _$AiChatData {
  // ignore: unused_element
  const AiChatData._();

  const factory AiChatData({
    required List<AiChatMessageDto> rows,
    required int totalPages,
  }) = _AiChatData;

  factory AiChatData.fromJson(Map<String, dynamic> json) =>
      _$AiChatDataFromJson(json);
}

/// A history message as the server sends it.
@freezed
abstract class AiChatMessageDto with _$AiChatMessageDto {
  const AiChatMessageDto._();

  const factory AiChatMessageDto({
    required String id,
    required String createdAt,
    required String role,
    required String content,

    /// The server sends it as an int or a string.
    dynamic localChatId,
    String? type,
    String? audioUrl,
    @Default([]) List<String> suggestions,
  }) = _AiChatMessageDto;

  factory AiChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageDtoFromJson(json);

  AiChatMessage toEntity() {
    return AiChatMessage(
      id: id,
      sender: role == 'assistant' ? 'bot' : 'user',
      createdAt: DateTime.parse(createdAt),
      type: type == 'audio' ? MessageType.audio : MessageType.text,
      value: type == 'audio' ? 'Voice Message' : content,
      localChatId: localChatId?.toString(),
      suggestions: suggestions,
      audioUrl:
          type == 'audio' && content.startsWith('http') ? content : audioUrl,
    );
  }
}

/// A bot message from the send and greeting responses.
AiChatMessage botMessageFromJson(Map<String, dynamic> json,
        {String? localChatId}) =>
    AiChatMessage(
      id: json['_id'] as String,
      sender: 'bot',
      type: MessageType.text,
      value: json['text'] as String,
      createdAt: json['createdAt'] == null
          ? clock.now()
          : DateTime.parse(json['createdAt'] as String),
      suggestions: List<String>.from(json['suggestions'] ?? const []),
      localChatId: localChatId,
    );

/// A send response: `{inResponse, outResponse}`, or empty when it was queued.
ChatReply chatReplyFromJson(Map<String, dynamic> json, String? localChatId) {
  final bot = json['outResponse'] as Map<String, dynamic>?;
  return ChatReply(
    userMessageId: (json['inResponse'] as Map<String, dynamic>?)?['_id'],
    bot: bot == null ? null : botMessageFromJson(bot, localChatId: localChatId),
  );
}
