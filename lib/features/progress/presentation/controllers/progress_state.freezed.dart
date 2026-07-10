// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProgressState<T> {
  T? get data;
  bool get isLoading;
  String? get error;
  bool get isSyncFailed;
  DateTime? get lastUpdated;

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProgressStateCopyWith<T, ProgressState<T>> get copyWith =>
      _$ProgressStateCopyWithImpl<T, ProgressState<T>>(
          this as ProgressState<T>, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProgressState<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isSyncFailed, isSyncFailed) ||
                other.isSyncFailed == isSyncFailed) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(data),
      isLoading,
      error,
      isSyncFailed,
      lastUpdated);

  @override
  String toString() {
    return 'ProgressState<$T>(data: $data, isLoading: $isLoading, error: $error, isSyncFailed: $isSyncFailed, lastUpdated: $lastUpdated)';
  }
}

/// @nodoc
abstract mixin class $ProgressStateCopyWith<T, $Res> {
  factory $ProgressStateCopyWith(
          ProgressState<T> value, $Res Function(ProgressState<T>) _then) =
      _$ProgressStateCopyWithImpl;
  @useResult
  $Res call(
      {T? data,
      bool isLoading,
      String? error,
      bool isSyncFailed,
      DateTime? lastUpdated});
}

/// @nodoc
class _$ProgressStateCopyWithImpl<T, $Res>
    implements $ProgressStateCopyWith<T, $Res> {
  _$ProgressStateCopyWithImpl(this._self, this._then);

  final ProgressState<T> _self;
  final $Res Function(ProgressState<T>) _then;

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? isLoading = null,
    Object? error = freezed,
    Object? isSyncFailed = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_self.copyWith(
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isSyncFailed: null == isSyncFailed
          ? _self.isSyncFailed
          : isSyncFailed // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _ProgressState<T> implements ProgressState<T> {
  const _ProgressState(
      {this.data,
      this.isLoading = false,
      this.error,
      this.isSyncFailed = false,
      this.lastUpdated});

  @override
  final T? data;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool isSyncFailed;
  @override
  final DateTime? lastUpdated;

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProgressStateCopyWith<T, _ProgressState<T>> get copyWith =>
      __$ProgressStateCopyWithImpl<T, _ProgressState<T>>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProgressState<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isSyncFailed, isSyncFailed) ||
                other.isSyncFailed == isSyncFailed) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(data),
      isLoading,
      error,
      isSyncFailed,
      lastUpdated);

  @override
  String toString() {
    return 'ProgressState<$T>(data: $data, isLoading: $isLoading, error: $error, isSyncFailed: $isSyncFailed, lastUpdated: $lastUpdated)';
  }
}

/// @nodoc
abstract mixin class _$ProgressStateCopyWith<T, $Res>
    implements $ProgressStateCopyWith<T, $Res> {
  factory _$ProgressStateCopyWith(
          _ProgressState<T> value, $Res Function(_ProgressState<T>) _then) =
      __$ProgressStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {T? data,
      bool isLoading,
      String? error,
      bool isSyncFailed,
      DateTime? lastUpdated});
}

/// @nodoc
class __$ProgressStateCopyWithImpl<T, $Res>
    implements _$ProgressStateCopyWith<T, $Res> {
  __$ProgressStateCopyWithImpl(this._self, this._then);

  final _ProgressState<T> _self;
  final $Res Function(_ProgressState<T>) _then;

  /// Create a copy of ProgressState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = freezed,
    Object? isLoading = null,
    Object? error = freezed,
    Object? isSyncFailed = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_ProgressState<T>(
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isSyncFailed: null == isSyncFailed
          ? _self.isSyncFailed
          : isSyncFailed // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
