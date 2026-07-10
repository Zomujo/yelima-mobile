// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiChatState {
  List<AiChatMessage> get messages;
  bool get isLoading;
  bool get isLoadingMore;
  bool get hasMoreMessages;
  bool get isOnline;
  bool get isSending;
  bool get syncPending;
  String? get error;
  int get currentPage;

  /// Create a copy of AiChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AiChatStateCopyWith<AiChatState> get copyWith =>
      _$AiChatStateCopyWithImpl<AiChatState>(this as AiChatState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AiChatState &&
            const DeepCollectionEquality().equals(other.messages, messages) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasMoreMessages, hasMoreMessages) ||
                other.hasMoreMessages == hasMoreMessages) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.isSending, isSending) ||
                other.isSending == isSending) &&
            (identical(other.syncPending, syncPending) ||
                other.syncPending == syncPending) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(messages),
      isLoading,
      isLoadingMore,
      hasMoreMessages,
      isOnline,
      isSending,
      syncPending,
      error,
      currentPage);

  @override
  String toString() {
    return 'AiChatState(messages: $messages, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMoreMessages: $hasMoreMessages, isOnline: $isOnline, isSending: $isSending, syncPending: $syncPending, error: $error, currentPage: $currentPage)';
  }
}

/// @nodoc
abstract mixin class $AiChatStateCopyWith<$Res> {
  factory $AiChatStateCopyWith(
          AiChatState value, $Res Function(AiChatState) _then) =
      _$AiChatStateCopyWithImpl;
  @useResult
  $Res call(
      {List<AiChatMessage> messages,
      bool isLoading,
      bool isLoadingMore,
      bool hasMoreMessages,
      bool isOnline,
      bool isSending,
      bool syncPending,
      String? error,
      int currentPage});
}

/// @nodoc
class _$AiChatStateCopyWithImpl<$Res> implements $AiChatStateCopyWith<$Res> {
  _$AiChatStateCopyWithImpl(this._self, this._then);

  final AiChatState _self;
  final $Res Function(AiChatState) _then;

  /// Create a copy of AiChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMoreMessages = null,
    Object? isOnline = null,
    Object? isSending = null,
    Object? syncPending = null,
    Object? error = freezed,
    Object? currentPage = null,
  }) {
    return _then(_self.copyWith(
      messages: null == messages
          ? _self.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AiChatMessage>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _self.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMoreMessages: null == hasMoreMessages
          ? _self.hasMoreMessages
          : hasMoreMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _self.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      isSending: null == isSending
          ? _self.isSending
          : isSending // ignore: cast_nullable_to_non_nullable
              as bool,
      syncPending: null == syncPending
          ? _self.syncPending
          : syncPending // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentPage: null == currentPage
          ? _self.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _AiChatState implements AiChatState {
  const _AiChatState(
      {final List<AiChatMessage> messages = const [],
      this.isLoading = false,
      this.isLoadingMore = false,
      this.hasMoreMessages = true,
      this.isOnline = true,
      this.isSending = false,
      this.syncPending = false,
      this.error,
      this.currentPage = 1})
      : _messages = messages;

  final List<AiChatMessage> _messages;
  @override
  @JsonKey()
  List<AiChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool hasMoreMessages;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  @JsonKey()
  final bool isSending;
  @override
  @JsonKey()
  final bool syncPending;
  @override
  final String? error;
  @override
  @JsonKey()
  final int currentPage;

  /// Create a copy of AiChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AiChatStateCopyWith<_AiChatState> get copyWith =>
      __$AiChatStateCopyWithImpl<_AiChatState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AiChatState &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasMoreMessages, hasMoreMessages) ||
                other.hasMoreMessages == hasMoreMessages) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.isSending, isSending) ||
                other.isSending == isSending) &&
            (identical(other.syncPending, syncPending) ||
                other.syncPending == syncPending) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_messages),
      isLoading,
      isLoadingMore,
      hasMoreMessages,
      isOnline,
      isSending,
      syncPending,
      error,
      currentPage);

  @override
  String toString() {
    return 'AiChatState(messages: $messages, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMoreMessages: $hasMoreMessages, isOnline: $isOnline, isSending: $isSending, syncPending: $syncPending, error: $error, currentPage: $currentPage)';
  }
}

/// @nodoc
abstract mixin class _$AiChatStateCopyWith<$Res>
    implements $AiChatStateCopyWith<$Res> {
  factory _$AiChatStateCopyWith(
          _AiChatState value, $Res Function(_AiChatState) _then) =
      __$AiChatStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<AiChatMessage> messages,
      bool isLoading,
      bool isLoadingMore,
      bool hasMoreMessages,
      bool isOnline,
      bool isSending,
      bool syncPending,
      String? error,
      int currentPage});
}

/// @nodoc
class __$AiChatStateCopyWithImpl<$Res> implements _$AiChatStateCopyWith<$Res> {
  __$AiChatStateCopyWithImpl(this._self, this._then);

  final _AiChatState _self;
  final $Res Function(_AiChatState) _then;

  /// Create a copy of AiChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? messages = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMoreMessages = null,
    Object? isOnline = null,
    Object? isSending = null,
    Object? syncPending = null,
    Object? error = freezed,
    Object? currentPage = null,
  }) {
    return _then(_AiChatState(
      messages: null == messages
          ? _self._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AiChatMessage>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _self.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMoreMessages: null == hasMoreMessages
          ? _self.hasMoreMessages
          : hasMoreMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _self.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      isSending: null == isSending
          ? _self.isSending
          : isSending // ignore: cast_nullable_to_non_nullable
              as bool,
      syncPending: null == syncPending
          ? _self.syncPending
          : syncPending // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentPage: null == currentPage
          ? _self.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
