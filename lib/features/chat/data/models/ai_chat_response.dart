import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ai_chat_message.dart';

part 'ai_chat_response.freezed.dart';
part 'ai_chat_response.g.dart';

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

@freezed
abstract class AiChatMessageDto with _$AiChatMessageDto {
  const AiChatMessageDto._();

  const factory AiChatMessageDto({
    required String id,
    required String createdAt,
    required String role,
    required String content,
    dynamic localChatId, // Use dynamic to handle int or String from API
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
      value: type == 'audio' ? "Voice Message" : content, // Display text
      localChatId: localChatId?.toString(),

      suggestions: suggestions,
      audioUrl: type == 'audio' && content.startsWith('http') ? content : audioUrl,
    );
  }
}
