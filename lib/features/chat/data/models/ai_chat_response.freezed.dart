// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_chat_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiChatResponse {
  AiChatData get data;

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AiChatResponseCopyWith<AiChatResponse> get copyWith =>
      _$AiChatResponseCopyWithImpl<AiChatResponse>(
          this as AiChatResponse, _$identity);

  /// Serializes this AiChatResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AiChatResponse &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data);

  @override
  String toString() {
    return 'AiChatResponse(data: $data)';
  }
}

/// @nodoc
abstract mixin class $AiChatResponseCopyWith<$Res> {
  factory $AiChatResponseCopyWith(
          AiChatResponse value, $Res Function(AiChatResponse) _then) =
      _$AiChatResponseCopyWithImpl;
  @useResult
  $Res call({AiChatData data});

  $AiChatDataCopyWith<$Res> get data;
}

/// @nodoc
class _$AiChatResponseCopyWithImpl<$Res>
    implements $AiChatResponseCopyWith<$Res> {
  _$AiChatResponseCopyWithImpl(this._self, this._then);

  final AiChatResponse _self;
  final $Res Function(AiChatResponse) _then;

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_self.copyWith(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as AiChatData,
    ));
  }

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiChatDataCopyWith<$Res> get data {
    return $AiChatDataCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _AiChatResponse extends AiChatResponse {
  const _AiChatResponse({required this.data}) : super._();
  factory _AiChatResponse.fromJson(Map<String, dynamic> json) =>
      _$AiChatResponseFromJson(json);

  @override
  final AiChatData data;

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AiChatResponseCopyWith<_AiChatResponse> get copyWith =>
      __$AiChatResponseCopyWithImpl<_AiChatResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AiChatResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AiChatResponse &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data);

  @override
  String toString() {
    return 'AiChatResponse(data: $data)';
  }
}

/// @nodoc
abstract mixin class _$AiChatResponseCopyWith<$Res>
    implements $AiChatResponseCopyWith<$Res> {
  factory _$AiChatResponseCopyWith(
          _AiChatResponse value, $Res Function(_AiChatResponse) _then) =
      __$AiChatResponseCopyWithImpl;
  @override
  @useResult
  $Res call({AiChatData data});

  @override
  $AiChatDataCopyWith<$Res> get data;
}

/// @nodoc
class __$AiChatResponseCopyWithImpl<$Res>
    implements _$AiChatResponseCopyWith<$Res> {
  __$AiChatResponseCopyWithImpl(this._self, this._then);

  final _AiChatResponse _self;
  final $Res Function(_AiChatResponse) _then;

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
  }) {
    return _then(_AiChatResponse(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as AiChatData,
    ));
  }

  /// Create a copy of AiChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiChatDataCopyWith<$Res> get data {
    return $AiChatDataCopyWith<$Res>(_self.data, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc
mixin _$AiChatData {
  List<AiChatMessageDto> get rows;
  int get totalPages;

  /// Create a copy of AiChatData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AiChatDataCopyWith<AiChatData> get copyWith =>
      _$AiChatDataCopyWithImpl<AiChatData>(this as AiChatData, _$identity);

  /// Serializes this AiChatData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AiChatData &&
            const DeepCollectionEquality().equals(other.rows, rows) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(rows), totalPages);

  @override
  String toString() {
    return 'AiChatData(rows: $rows, totalPages: $totalPages)';
  }
}

/// @nodoc
abstract mixin class $AiChatDataCopyWith<$Res> {
  factory $AiChatDataCopyWith(
          AiChatData value, $Res Function(AiChatData) _then) =
      _$AiChatDataCopyWithImpl;
  @useResult
  $Res call({List<AiChatMessageDto> rows, int totalPages});
}

/// @nodoc
class _$AiChatDataCopyWithImpl<$Res> implements $AiChatDataCopyWith<$Res> {
  _$AiChatDataCopyWithImpl(this._self, this._then);

  final AiChatData _self;
  final $Res Function(AiChatData) _then;

  /// Create a copy of AiChatData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rows = null,
    Object? totalPages = null,
  }) {
    return _then(_self.copyWith(
      rows: null == rows
          ? _self.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as List<AiChatMessageDto>,
      totalPages: null == totalPages
          ? _self.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AiChatData extends AiChatData {
  const _AiChatData(
      {required final List<AiChatMessageDto> rows, required this.totalPages})
      : _rows = rows,
        super._();
  factory _AiChatData.fromJson(Map<String, dynamic> json) =>
      _$AiChatDataFromJson(json);

  final List<AiChatMessageDto> _rows;
  @override
  List<AiChatMessageDto> get rows {
    if (_rows is EqualUnmodifiableListView) return _rows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rows);
  }

  @override
  final int totalPages;

  /// Create a copy of AiChatData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AiChatDataCopyWith<_AiChatData> get copyWith =>
      __$AiChatDataCopyWithImpl<_AiChatData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AiChatDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AiChatData &&
            const DeepCollectionEquality().equals(other._rows, _rows) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_rows), totalPages);

  @override
  String toString() {
    return 'AiChatData(rows: $rows, totalPages: $totalPages)';
  }
}

/// @nodoc
abstract mixin class _$AiChatDataCopyWith<$Res>
    implements $AiChatDataCopyWith<$Res> {
  factory _$AiChatDataCopyWith(
          _AiChatData value, $Res Function(_AiChatData) _then) =
      __$AiChatDataCopyWithImpl;
  @override
  @useResult
  $Res call({List<AiChatMessageDto> rows, int totalPages});
}

/// @nodoc
class __$AiChatDataCopyWithImpl<$Res> implements _$AiChatDataCopyWith<$Res> {
  __$AiChatDataCopyWithImpl(this._self, this._then);

  final _AiChatData _self;
  final $Res Function(_AiChatData) _then;

  /// Create a copy of AiChatData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? rows = null,
    Object? totalPages = null,
  }) {
    return _then(_AiChatData(
      rows: null == rows
          ? _self._rows
          : rows // ignore: cast_nullable_to_non_nullable
              as List<AiChatMessageDto>,
      totalPages: null == totalPages
          ? _self.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$AiChatMessageDto {
  String get id;
  String get createdAt;
  String get role;
  String get content;
  dynamic get localChatId; // Use dynamic to handle int or String from API
  String? get type;
  String? get audioUrl;
  List<String> get suggestions;

  /// Create a copy of AiChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AiChatMessageDtoCopyWith<AiChatMessageDto> get copyWith =>
      _$AiChatMessageDtoCopyWithImpl<AiChatMessageDto>(
          this as AiChatMessageDto, _$identity);

  /// Serializes this AiChatMessageDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AiChatMessageDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality()
                .equals(other.localChatId, localChatId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            const DeepCollectionEquality()
                .equals(other.suggestions, suggestions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      role,
      content,
      const DeepCollectionEquality().hash(localChatId),
      type,
      audioUrl,
      const DeepCollectionEquality().hash(suggestions));

  @override
  String toString() {
    return 'AiChatMessageDto(id: $id, createdAt: $createdAt, role: $role, content: $content, localChatId: $localChatId, type: $type, audioUrl: $audioUrl, suggestions: $suggestions)';
  }
}

/// @nodoc
abstract mixin class $AiChatMessageDtoCopyWith<$Res> {
  factory $AiChatMessageDtoCopyWith(
          AiChatMessageDto value, $Res Function(AiChatMessageDto) _then) =
      _$AiChatMessageDtoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String createdAt,
      String role,
      String content,
      dynamic localChatId,
      String? type,
      String? audioUrl,
      List<String> suggestions});
}

/// @nodoc
class _$AiChatMessageDtoCopyWithImpl<$Res>
    implements $AiChatMessageDtoCopyWith<$Res> {
  _$AiChatMessageDtoCopyWithImpl(this._self, this._then);

  final AiChatMessageDto _self;
  final $Res Function(AiChatMessageDto) _then;

  /// Create a copy of AiChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? role = null,
    Object? content = null,
    Object? localChatId = freezed,
    Object? type = freezed,
    Object? audioUrl = freezed,
    Object? suggestions = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      localChatId: freezed == localChatId
          ? _self.localChatId
          : localChatId // ignore: cast_nullable_to_non_nullable
              as dynamic,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: freezed == audioUrl
          ? _self.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      suggestions: null == suggestions
          ? _self.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AiChatMessageDto extends AiChatMessageDto {
  const _AiChatMessageDto(
      {required this.id,
      required this.createdAt,
      required this.role,
      required this.content,
      this.localChatId,
      this.type,
      this.audioUrl,
      final List<String> suggestions = const []})
      : _suggestions = suggestions,
        super._();
  factory _AiChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageDtoFromJson(json);

  @override
  final String id;
  @override
  final String createdAt;
  @override
  final String role;
  @override
  final String content;
  @override
  final dynamic localChatId;
// Use dynamic to handle int or String from API
  @override
  final String? type;
  @override
  final String? audioUrl;
  final List<String> _suggestions;
  @override
  @JsonKey()
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  /// Create a copy of AiChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AiChatMessageDtoCopyWith<_AiChatMessageDto> get copyWith =>
      __$AiChatMessageDtoCopyWithImpl<_AiChatMessageDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AiChatMessageDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AiChatMessageDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality()
                .equals(other.localChatId, localChatId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      role,
      content,
      const DeepCollectionEquality().hash(localChatId),
      type,
      audioUrl,
      const DeepCollectionEquality().hash(_suggestions));

  @override
  String toString() {
    return 'AiChatMessageDto(id: $id, createdAt: $createdAt, role: $role, content: $content, localChatId: $localChatId, type: $type, audioUrl: $audioUrl, suggestions: $suggestions)';
  }
}

/// @nodoc
abstract mixin class _$AiChatMessageDtoCopyWith<$Res>
    implements $AiChatMessageDtoCopyWith<$Res> {
  factory _$AiChatMessageDtoCopyWith(
          _AiChatMessageDto value, $Res Function(_AiChatMessageDto) _then) =
      __$AiChatMessageDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String createdAt,
      String role,
      String content,
      dynamic localChatId,
      String? type,
      String? audioUrl,
      List<String> suggestions});
}

/// @nodoc
class __$AiChatMessageDtoCopyWithImpl<$Res>
    implements _$AiChatMessageDtoCopyWith<$Res> {
  __$AiChatMessageDtoCopyWithImpl(this._self, this._then);

  final _AiChatMessageDto _self;
  final $Res Function(_AiChatMessageDto) _then;

  /// Create a copy of AiChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? role = null,
    Object? content = null,
    Object? localChatId = freezed,
    Object? type = freezed,
    Object? audioUrl = freezed,
    Object? suggestions = null,
  }) {
    return _then(_AiChatMessageDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      localChatId: freezed == localChatId
          ? _self.localChatId
          : localChatId // ignore: cast_nullable_to_non_nullable
              as dynamic,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: freezed == audioUrl
          ? _self.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      suggestions: null == suggestions
          ? _self._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
