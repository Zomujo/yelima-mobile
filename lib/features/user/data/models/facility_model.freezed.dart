// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FacilityModel {
  String get id;
  String get name;
  String? get phoneNumber;
  String? get createdAt;
  String? get updatedAt;

  /// Create a copy of FacilityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FacilityModelCopyWith<FacilityModel> get copyWith =>
      _$FacilityModelCopyWithImpl<FacilityModel>(
          this as FacilityModel, _$identity);

  /// Serializes this FacilityModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FacilityModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, phoneNumber, createdAt, updatedAt);

  @override
  String toString() {
    return 'FacilityModel(id: $id, name: $name, phoneNumber: $phoneNumber, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $FacilityModelCopyWith<$Res> {
  factory $FacilityModelCopyWith(
          FacilityModel value, $Res Function(FacilityModel) _then) =
      _$FacilityModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? phoneNumber,
      String? createdAt,
      String? updatedAt});
}

/// @nodoc
class _$FacilityModelCopyWithImpl<$Res>
    implements $FacilityModelCopyWith<$Res> {
  _$FacilityModelCopyWithImpl(this._self, this._then);

  final FacilityModel _self;
  final $Res Function(FacilityModel) _then;

  /// Create a copy of FacilityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phoneNumber = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _self.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _FacilityModel implements FacilityModel {
  const _FacilityModel(
      {required this.id,
      required this.name,
      this.phoneNumber,
      this.createdAt,
      this.updatedAt});
  factory _FacilityModel.fromJson(Map<String, dynamic> json) =>
      _$FacilityModelFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? phoneNumber;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  /// Create a copy of FacilityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FacilityModelCopyWith<_FacilityModel> get copyWith =>
      __$FacilityModelCopyWithImpl<_FacilityModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FacilityModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FacilityModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, phoneNumber, createdAt, updatedAt);

  @override
  String toString() {
    return 'FacilityModel(id: $id, name: $name, phoneNumber: $phoneNumber, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$FacilityModelCopyWith<$Res>
    implements $FacilityModelCopyWith<$Res> {
  factory _$FacilityModelCopyWith(
          _FacilityModel value, $Res Function(_FacilityModel) _then) =
      __$FacilityModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? phoneNumber,
      String? createdAt,
      String? updatedAt});
}

/// @nodoc
class __$FacilityModelCopyWithImpl<$Res>
    implements _$FacilityModelCopyWith<$Res> {
  __$FacilityModelCopyWithImpl(this._self, this._then);

  final _FacilityModel _self;
  final $Res Function(_FacilityModel) _then;

  /// Create a copy of FacilityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phoneNumber = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_FacilityModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _self.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$FacilityListResponse {
  List<FacilityModel> get rows;
  int get total;
  int get pageSize;
  int get page;
  int? get nextPage;
  int? get prevPage;
  int get totalPages;

  /// Create a copy of FacilityListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FacilityListResponseCopyWith<FacilityListResponse> get copyWith =>
      _$FacilityListResponseCopyWithImpl<FacilityListResponse>(
          this as FacilityListResponse, _$identity);

  /// Serializes this FacilityListResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FacilityListResponse &&
            const DeepCollectionEquality().equals(other.rows, rows) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.nextPage, nextPage) ||
                other.nextPage == nextPage) &&
            (identical(other.prevPage, prevPage) ||
                other.prevPage == prevPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(rows),
      total,
      pageSize,
      page,
      nextPage,
      prevPage,
      totalPages);

  @override
  String toString() {
    return 'FacilityListResponse(rows: $rows, total: $total, pageSize: $pageSize, page: $page, nextPage: $nextPage, prevPage: $prevPage, totalPages: $totalPages)';
  }
}

/// @nodoc
abstract mixin class $FacilityListResponseCopyWith<$Res> {
  factory $FacilityListResponseCopyWith(FacilityListResponse value,
          $Res Function(FacilityListResponse) _then) =
      _$FacilityListResponseCopyWithImpl;
  @useResult
  $Res call(
      {List<FacilityModel> rows,
      int total,
      int pageSize,
      int page,
      int? nextPage,
      int? prevPage,
      int totalPages});
}

/// @nodoc
class _$FacilityListResponseCopyWithImpl<$Res>
    implements $FacilityListResponseCopyWith<$Res> {
  _$FacilityListResponseCopyWithImpl(this._self, this._then);

  final FacilityListResponse _self;
  final $Res Function(FacilityListResponse) _then;

  /// Create a copy of FacilityListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rows = null,
    Object? total = null,
    Object? pageSize = null,
    Object? page = null,
    Object? nextPage = freezed,
    Object? prevPage = freezed,
    Object? totalPages = null,
  }) {
    return _then(_self.copyWith(
      rows: null == rows
          ? _self.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as List<FacilityModel>,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _self.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      nextPage: freezed == nextPage
          ? _self.nextPage
          : nextPage // ignore: cast_nullable_to_non_nullable
              as int?,
      prevPage: freezed == prevPage
          ? _self.prevPage
          : prevPage // ignore: cast_nullable_to_non_nullable
              as int?,
      totalPages: null == totalPages
          ? _self.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _FacilityListResponse implements FacilityListResponse {
  const _FacilityListResponse(
      {required final List<FacilityModel> rows,
      required this.total,
      required this.pageSize,
      required this.page,
      this.nextPage,
      this.prevPage,
      required this.totalPages})
      : _rows = rows;
  factory _FacilityListResponse.fromJson(Map<String, dynamic> json) =>
      _$FacilityListResponseFromJson(json);

  final List<FacilityModel> _rows;
  @override
  List<FacilityModel> get rows {
    if (_rows is EqualUnmodifiableListView) return _rows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rows);
  }

  @override
  final int total;
  @override
  final int pageSize;
  @override
  final int page;
  @override
  final int? nextPage;
  @override
  final int? prevPage;
  @override
  final int totalPages;

  /// Create a copy of FacilityListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FacilityListResponseCopyWith<_FacilityListResponse> get copyWith =>
      __$FacilityListResponseCopyWithImpl<_FacilityListResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FacilityListResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FacilityListResponse &&
            const DeepCollectionEquality().equals(other._rows, _rows) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.nextPage, nextPage) ||
                other.nextPage == nextPage) &&
            (identical(other.prevPage, prevPage) ||
                other.prevPage == prevPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_rows),
      total,
      pageSize,
      page,
      nextPage,
      prevPage,
      totalPages);

  @override
  String toString() {
    return 'FacilityListResponse(rows: $rows, total: $total, pageSize: $pageSize, page: $page, nextPage: $nextPage, prevPage: $prevPage, totalPages: $totalPages)';
  }
}

/// @nodoc
abstract mixin class _$FacilityListResponseCopyWith<$Res>
    implements $FacilityListResponseCopyWith<$Res> {
  factory _$FacilityListResponseCopyWith(_FacilityListResponse value,
          $Res Function(_FacilityListResponse) _then) =
      __$FacilityListResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<FacilityModel> rows,
      int total,
      int pageSize,
      int page,
      int? nextPage,
      int? prevPage,
      int totalPages});
}

/// @nodoc
class __$FacilityListResponseCopyWithImpl<$Res>
    implements _$FacilityListResponseCopyWith<$Res> {
  __$FacilityListResponseCopyWithImpl(this._self, this._then);

  final _FacilityListResponse _self;
  final $Res Function(_FacilityListResponse) _then;

  /// Create a copy of FacilityListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? rows = null,
    Object? total = null,
    Object? pageSize = null,
    Object? page = null,
    Object? nextPage = freezed,
    Object? prevPage = freezed,
    Object? totalPages = null,
  }) {
    return _then(_FacilityListResponse(
      rows: null == rows
          ? _self._rows
          : rows // ignore: cast_nullable_to_non_nullable
              as List<FacilityModel>,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _self.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      nextPage: freezed == nextPage
          ? _self.nextPage
          : nextPage // ignore: cast_nullable_to_non_nullable
              as int?,
      prevPage: freezed == prevPage
          ? _self.prevPage
          : prevPage // ignore: cast_nullable_to_non_nullable
              as int?,
      totalPages: null == totalPages
          ? _self.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
