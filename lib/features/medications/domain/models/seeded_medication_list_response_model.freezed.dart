// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seeded_medication_list_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeededMedicationListResponseModel {
  List<SeededMedicationModel> get rows;
  int get total;
  int get pageSize;
  int get page;
  int get totalPages;

  /// Create a copy of SeededMedicationListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SeededMedicationListResponseModelCopyWith<SeededMedicationListResponseModel>
      get copyWith => _$SeededMedicationListResponseModelCopyWithImpl<
              SeededMedicationListResponseModel>(
          this as SeededMedicationListResponseModel, _$identity);

  /// Serializes this SeededMedicationListResponseModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SeededMedicationListResponseModel &&
            const DeepCollectionEquality().equals(other.rows, rows) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.page, page) || other.page == page) &&
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
      totalPages);

  @override
  String toString() {
    return 'SeededMedicationListResponseModel(rows: $rows, total: $total, pageSize: $pageSize, page: $page, totalPages: $totalPages)';
  }
}

/// @nodoc
abstract mixin class $SeededMedicationListResponseModelCopyWith<$Res> {
  factory $SeededMedicationListResponseModelCopyWith(
          SeededMedicationListResponseModel value,
          $Res Function(SeededMedicationListResponseModel) _then) =
      _$SeededMedicationListResponseModelCopyWithImpl;
  @useResult
  $Res call(
      {List<SeededMedicationModel> rows,
      int total,
      int pageSize,
      int page,
      int totalPages});
}

/// @nodoc
class _$SeededMedicationListResponseModelCopyWithImpl<$Res>
    implements $SeededMedicationListResponseModelCopyWith<$Res> {
  _$SeededMedicationListResponseModelCopyWithImpl(this._self, this._then);

  final SeededMedicationListResponseModel _self;
  final $Res Function(SeededMedicationListResponseModel) _then;

  /// Create a copy of SeededMedicationListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rows = null,
    Object? total = null,
    Object? pageSize = null,
    Object? page = null,
    Object? totalPages = null,
  }) {
    return _then(_self.copyWith(
      rows: null == rows
          ? _self.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as List<SeededMedicationModel>,
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
      totalPages: null == totalPages
          ? _self.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SeededMedicationListResponseModel
    implements SeededMedicationListResponseModel {
  const _SeededMedicationListResponseModel(
      {final List<SeededMedicationModel> rows = const [],
      this.total = 0,
      this.pageSize = 10,
      this.page = 1,
      this.totalPages = 0})
      : _rows = rows;
  factory _SeededMedicationListResponseModel.fromJson(
          Map<String, dynamic> json) =>
      _$SeededMedicationListResponseModelFromJson(json);

  final List<SeededMedicationModel> _rows;
  @override
  @JsonKey()
  List<SeededMedicationModel> get rows {
    if (_rows is EqualUnmodifiableListView) return _rows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rows);
  }

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int pageSize;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int totalPages;

  /// Create a copy of SeededMedicationListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SeededMedicationListResponseModelCopyWith<
          _SeededMedicationListResponseModel>
      get copyWith => __$SeededMedicationListResponseModelCopyWithImpl<
          _SeededMedicationListResponseModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SeededMedicationListResponseModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SeededMedicationListResponseModel &&
            const DeepCollectionEquality().equals(other._rows, _rows) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.page, page) || other.page == page) &&
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
      totalPages);

  @override
  String toString() {
    return 'SeededMedicationListResponseModel(rows: $rows, total: $total, pageSize: $pageSize, page: $page, totalPages: $totalPages)';
  }
}

/// @nodoc
abstract mixin class _$SeededMedicationListResponseModelCopyWith<$Res>
    implements $SeededMedicationListResponseModelCopyWith<$Res> {
  factory _$SeededMedicationListResponseModelCopyWith(
          _SeededMedicationListResponseModel value,
          $Res Function(_SeededMedicationListResponseModel) _then) =
      __$SeededMedicationListResponseModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<SeededMedicationModel> rows,
      int total,
      int pageSize,
      int page,
      int totalPages});
}

/// @nodoc
class __$SeededMedicationListResponseModelCopyWithImpl<$Res>
    implements _$SeededMedicationListResponseModelCopyWith<$Res> {
  __$SeededMedicationListResponseModelCopyWithImpl(this._self, this._then);

  final _SeededMedicationListResponseModel _self;
  final $Res Function(_SeededMedicationListResponseModel) _then;

  /// Create a copy of SeededMedicationListResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? rows = null,
    Object? total = null,
    Object? pageSize = null,
    Object? page = null,
    Object? totalPages = null,
  }) {
    return _then(_SeededMedicationListResponseModel(
      rows: null == rows
          ? _self._rows
          : rows // ignore: cast_nullable_to_non_nullable
              as List<SeededMedicationModel>,
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
      totalPages: null == totalPages
          ? _self.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
