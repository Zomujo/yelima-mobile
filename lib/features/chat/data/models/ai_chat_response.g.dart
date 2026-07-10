// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiChatResponse _$AiChatResponseFromJson(Map<String, dynamic> json) =>
    _AiChatResponse(
      data: AiChatData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AiChatResponseToJson(_AiChatResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
    };

_AiChatData _$AiChatDataFromJson(Map<String, dynamic> json) => _AiChatData(
      rows: (json['rows'] as List<dynamic>)
          .map((e) => AiChatMessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$AiChatDataToJson(_AiChatData instance) =>
    <String, dynamic>{
      'rows': instance.rows.map((e) => e.toJson()).toList(),
      'totalPages': instance.totalPages,
    };

_AiChatMessageDto _$AiChatMessageDtoFromJson(Map<String, dynamic> json) =>
    _AiChatMessageDto(
      id: json['id'] as String,
      createdAt: json['createdAt'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      localChatId: json['localChatId'],
      type: json['type'] as String?,
      audioUrl: json['audioUrl'] as String?,
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AiChatMessageDtoToJson(_AiChatMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'role': instance.role,
      'content': instance.content,
      if (instance.localChatId case final value?) 'localChatId': value,
      if (instance.type case final value?) 'type': value,
      if (instance.audioUrl case final value?) 'audioUrl': value,
      'suggestions': instance.suggestions,
    };
