// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiChatMessage {
  String get id;
  String get sender; // 'bot' or 'user'
  MessageType get type;
  String get value;
  DateTime get createdAt;
  MessageStatus get status;
  List<String> get suggestions;
  String? get localChatId;
  String? get audioUrl;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AiChatMessageCopyWith<AiChatMessage> get copyWith =>
      _$AiChatMessageCopyWithImpl<AiChatMessage>(
          this as AiChatMessage, _$identity);

  /// Serializes this AiChatMessage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AiChatMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other.suggestions, suggestions) &&
            (identical(other.localChatId, localChatId) ||
                other.localChatId == localChatId) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      sender,
      type,
      value,
      createdAt,
      status,
      const DeepCollectionEquality().hash(suggestions),
      localChatId,
      audioUrl);

  @override
  String toString() {
    return 'AiChatMessage(id: $id, sender: $sender, type: $type, value: $value, createdAt: $createdAt, status: $status, suggestions: $suggestions, localChatId: $localChatId, audioUrl: $audioUrl)';
  }
}

/// @nodoc
abstract mixin class $AiChatMessageCopyWith<$Res> {
  factory $AiChatMessageCopyWith(
          AiChatMessage value, $Res Function(AiChatMessage) _then) =
      _$AiChatMessageCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String sender,
      MessageType type,
      String value,
      DateTime createdAt,
      MessageStatus status,
      List<String> suggestions,
      String? localChatId,
      String? audioUrl});
}

/// @nodoc
class _$AiChatMessageCopyWithImpl<$Res>
    implements $AiChatMessageCopyWith<$Res> {
  _$AiChatMessageCopyWithImpl(this._self, this._then);

  final AiChatMessage _self;
  final $Res Function(AiChatMessage) _then;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? type = null,
    Object? value = null,
    Object? createdAt = null,
    Object? status = null,
    Object? suggestions = null,
    Object? localChatId = freezed,
    Object? audioUrl = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _self.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
      suggestions: null == suggestions
          ? _self.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      localChatId: freezed == localChatId
          ? _self.localChatId
          : localChatId // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: freezed == audioUrl
          ? _self.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AiChatMessage extends AiChatMessage {
  const _AiChatMessage(
      {required this.id,
      required this.sender,
      required this.type,
      required this.value,
      required this.createdAt,
      this.status = MessageStatus.sent,
      final List<String> suggestions = const [],
      this.localChatId,
      this.audioUrl})
      : _suggestions = suggestions,
        super._();
  factory _AiChatMessage.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageFromJson(json);

  @override
  final String id;
  @override
  final String sender;
// 'bot' or 'user'
  @override
  final MessageType type;
  @override
  final String value;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final MessageStatus status;
  final List<String> _suggestions;
  @override
  @JsonKey()
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  final String? localChatId;
  @override
  final String? audioUrl;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AiChatMessageCopyWith<_AiChatMessage> get copyWith =>
      __$AiChatMessageCopyWithImpl<_AiChatMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AiChatMessageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AiChatMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions) &&
            (identical(other.localChatId, localChatId) ||
                other.localChatId == localChatId) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      sender,
      type,
      value,
      createdAt,
      status,
      const DeepCollectionEquality().hash(_suggestions),
      localChatId,
      audioUrl);

  @override
  String toString() {
    return 'AiChatMessage(id: $id, sender: $sender, type: $type, value: $value, createdAt: $createdAt, status: $status, suggestions: $suggestions, localChatId: $localChatId, audioUrl: $audioUrl)';
  }
}

/// @nodoc
abstract mixin class _$AiChatMessageCopyWith<$Res>
    implements $AiChatMessageCopyWith<$Res> {
  factory _$AiChatMessageCopyWith(
          _AiChatMessage value, $Res Function(_AiChatMessage) _then) =
      __$AiChatMessageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String sender,
      MessageType type,
      String value,
      DateTime createdAt,
      MessageStatus status,
      List<String> suggestions,
      String? localChatId,
      String? audioUrl});
}

/// @nodoc
class __$AiChatMessageCopyWithImpl<$Res>
    implements _$AiChatMessageCopyWith<$Res> {
  __$AiChatMessageCopyWithImpl(this._self, this._then);

  final _AiChatMessage _self;
  final $Res Function(_AiChatMessage) _then;

  /// Create a copy of AiChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? type = null,
    Object? value = null,
    Object? createdAt = null,
    Object? status = null,
    Object? suggestions = null,
    Object? localChatId = freezed,
    Object? audioUrl = freezed,
  }) {
    return _then(_AiChatMessage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _self.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
      suggestions: null == suggestions
          ? _self._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      localChatId: freezed == localChatId
          ? _self.localChatId
          : localChatId // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: freezed == audioUrl
          ? _self.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
