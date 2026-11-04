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
  AppFailure? get error;

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
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), isLoading, error);

  @override
  String toString() {
    return 'ProgressState<$T>(data: $data, isLoading: $isLoading, error: $error)';
  }
}

/// @nodoc
abstract mixin class $ProgressStateCopyWith<T, $Res> {
  factory $ProgressStateCopyWith(
          ProgressState<T> value, $Res Function(ProgressState<T>) _then) =
      _$ProgressStateCopyWithImpl;
  @useResult
  $Res call({T? data, bool isLoading, AppFailure? error});
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
              as AppFailure?,
    ));
  }
}

/// @nodoc

class _ProgressState<T> implements ProgressState<T> {
  const _ProgressState({this.data, this.isLoading = false, this.error});

  @override
  final T? data;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final AppFailure? error;

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
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), isLoading, error);

  @override
  String toString() {
    return 'ProgressState<$T>(data: $data, isLoading: $isLoading, error: $error)';
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
  $Res call({T? data, bool isLoading, AppFailure? error});
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
              as AppFailure?,
    ));
  }
}

/// @nodoc
mixin _$ProgressCharts {
  ProgressState<BPTrend> get bpTrendState;
  ProgressState<VitalTrend> get glucoseTrendState;

  /// Create a copy of ProgressCharts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProgressChartsCopyWith<ProgressCharts> get copyWith =>
      _$ProgressChartsCopyWithImpl<ProgressCharts>(
          this as ProgressCharts, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProgressCharts &&
            (identical(other.bpTrendState, bpTrendState) ||
                other.bpTrendState == bpTrendState) &&
            (identical(other.glucoseTrendState, glucoseTrendState) ||
                other.glucoseTrendState == glucoseTrendState));
  }

  @override
  int get hashCode => Object.hash(runtimeType, bpTrendState, glucoseTrendState);

  @override
  String toString() {
    return 'ProgressCharts(bpTrendState: $bpTrendState, glucoseTrendState: $glucoseTrendState)';
  }
}

/// @nodoc
abstract mixin class $ProgressChartsCopyWith<$Res> {
  factory $ProgressChartsCopyWith(
          ProgressCharts value, $Res Function(ProgressCharts) _then) =
      _$ProgressChartsCopyWithImpl;
  @useResult
  $Res call(
      {ProgressState<BPTrend> bpTrendState,
      ProgressState<VitalTrend> glucoseTrendState});

  $ProgressStateCopyWith<BPTrend, $Res> get bpTrendState;
  $ProgressStateCopyWith<VitalTrend, $Res> get glucoseTrendState;
}

/// @nodoc
class _$ProgressChartsCopyWithImpl<$Res>
    implements $ProgressChartsCopyWith<$Res> {
  _$ProgressChartsCopyWithImpl(this._self, this._then);

  final ProgressCharts _self;
  final $Res Function(ProgressCharts) _then;

  /// Create a copy of ProgressCharts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bpTrendState = null,
    Object? glucoseTrendState = null,
  }) {
    return _then(_self.copyWith(
      bpTrendState: null == bpTrendState
          ? _self.bpTrendState
          : bpTrendState // ignore: cast_nullable_to_non_nullable
              as ProgressState<BPTrend>,
      glucoseTrendState: null == glucoseTrendState
          ? _self.glucoseTrendState
          : glucoseTrendState // ignore: cast_nullable_to_non_nullable
              as ProgressState<VitalTrend>,
    ));
  }

  /// Create a copy of ProgressCharts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProgressStateCopyWith<BPTrend, $Res> get bpTrendState {
    return $ProgressStateCopyWith<BPTrend, $Res>(_self.bpTrendState, (value) {
      return _then(_self.copyWith(bpTrendState: value));
    });
  }

  /// Create a copy of ProgressCharts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProgressStateCopyWith<VitalTrend, $Res> get glucoseTrendState {
    return $ProgressStateCopyWith<VitalTrend, $Res>(_self.glucoseTrendState,
        (value) {
      return _then(_self.copyWith(glucoseTrendState: value));
    });
  }
}

/// @nodoc

class _ProgressCharts implements ProgressCharts {
  const _ProgressCharts(
      {this.bpTrendState = const ProgressState(isLoading: true),
      this.glucoseTrendState = const ProgressState(isLoading: true)});

  @override
  @JsonKey()
  final ProgressState<BPTrend> bpTrendState;
  @override
  @JsonKey()
  final ProgressState<VitalTrend> glucoseTrendState;

  /// Create a copy of ProgressCharts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProgressChartsCopyWith<_ProgressCharts> get copyWith =>
      __$ProgressChartsCopyWithImpl<_ProgressCharts>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProgressCharts &&
            (identical(other.bpTrendState, bpTrendState) ||
                other.bpTrendState == bpTrendState) &&
            (identical(other.glucoseTrendState, glucoseTrendState) ||
                other.glucoseTrendState == glucoseTrendState));
  }

  @override
  int get hashCode => Object.hash(runtimeType, bpTrendState, glucoseTrendState);

  @override
  String toString() {
    return 'ProgressCharts(bpTrendState: $bpTrendState, glucoseTrendState: $glucoseTrendState)';
  }
}

/// @nodoc
abstract mixin class _$ProgressChartsCopyWith<$Res>
    implements $ProgressChartsCopyWith<$Res> {
  factory _$ProgressChartsCopyWith(
          _ProgressCharts value, $Res Function(_ProgressCharts) _then) =
      __$ProgressChartsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {ProgressState<BPTrend> bpTrendState,
      ProgressState<VitalTrend> glucoseTrendState});

  @override
  $ProgressStateCopyWith<BPTrend, $Res> get bpTrendState;
  @override
  $ProgressStateCopyWith<VitalTrend, $Res> get glucoseTrendState;
}

/// @nodoc
class __$ProgressChartsCopyWithImpl<$Res>
    implements _$ProgressChartsCopyWith<$Res> {
  __$ProgressChartsCopyWithImpl(this._self, this._then);

  final _ProgressCharts _self;
  final $Res Function(_ProgressCharts) _then;

  /// Create a copy of ProgressCharts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bpTrendState = null,
    Object? glucoseTrendState = null,
  }) {
    return _then(_ProgressCharts(
      bpTrendState: null == bpTrendState
          ? _self.bpTrendState
          : bpTrendState // ignore: cast_nullable_to_non_nullable
              as ProgressState<BPTrend>,
      glucoseTrendState: null == glucoseTrendState
          ? _self.glucoseTrendState
          : glucoseTrendState // ignore: cast_nullable_to_non_nullable
              as ProgressState<VitalTrend>,
    ));
  }

  /// Create a copy of ProgressCharts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProgressStateCopyWith<BPTrend, $Res> get bpTrendState {
    return $ProgressStateCopyWith<BPTrend, $Res>(_self.bpTrendState, (value) {
      return _then(_self.copyWith(bpTrendState: value));
    });
  }

  /// Create a copy of ProgressCharts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProgressStateCopyWith<VitalTrend, $Res> get glucoseTrendState {
    return $ProgressStateCopyWith<VitalTrend, $Res>(_self.glucoseTrendState,
        (value) {
      return _then(_self.copyWith(glucoseTrendState: value));
    });
  }
}

// dart format on
