// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiChatMessage _$AiChatMessageFromJson(Map<String, dynamic> json) =>
    _AiChatMessage(
      id: json['id'] as String,
      sender: json['sender'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      value: json['value'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
          MessageStatus.sent,
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      localChatId: json['localChatId'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );

Map<String, dynamic> _$AiChatMessageToJson(_AiChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'value': instance.value,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$MessageStatusEnumMap[instance.status]!,
      'suggestions': instance.suggestions,
      if (instance.localChatId case final value?) 'localChatId': value,
      if (instance.audioUrl case final value?) 'audioUrl': value,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.audio: 'audio',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.failed: 'failed',
};
