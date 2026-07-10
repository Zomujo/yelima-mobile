// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_metrics_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeMetricsState {
  bool get isLoading;
  String? get errorMessage;
  HomeMetricsEntity? get metrics;

  /// Create a copy of HomeMetricsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HomeMetricsStateCopyWith<HomeMetricsState> get copyWith =>
      _$HomeMetricsStateCopyWithImpl<HomeMetricsState>(
          this as HomeMetricsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HomeMetricsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.metrics, metrics) || other.metrics == metrics));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, errorMessage, metrics);

  @override
  String toString() {
    return 'HomeMetricsState(isLoading: $isLoading, errorMessage: $errorMessage, metrics: $metrics)';
  }
}

/// @nodoc
abstract mixin class $HomeMetricsStateCopyWith<$Res> {
  factory $HomeMetricsStateCopyWith(
          HomeMetricsState value, $Res Function(HomeMetricsState) _then) =
      _$HomeMetricsStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, String? errorMessage, HomeMetricsEntity? metrics});
}

/// @nodoc
class _$HomeMetricsStateCopyWithImpl<$Res>
    implements $HomeMetricsStateCopyWith<$Res> {
  _$HomeMetricsStateCopyWithImpl(this._self, this._then);

  final HomeMetricsState _self;
  final $Res Function(HomeMetricsState) _then;

  /// Create a copy of HomeMetricsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? metrics = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      metrics: freezed == metrics
          ? _self.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as HomeMetricsEntity?,
    ));
  }
}

/// @nodoc

class _HomeMetricsState extends HomeMetricsState {
  const _HomeMetricsState(
      {this.isLoading = false, this.errorMessage = null, this.metrics = null})
      : super._();

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String? errorMessage;
  @override
  @JsonKey()
  final HomeMetricsEntity? metrics;

  /// Create a copy of HomeMetricsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HomeMetricsStateCopyWith<_HomeMetricsState> get copyWith =>
      __$HomeMetricsStateCopyWithImpl<_HomeMetricsState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HomeMetricsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.metrics, metrics) || other.metrics == metrics));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, errorMessage, metrics);

  @override
  String toString() {
    return 'HomeMetricsState(isLoading: $isLoading, errorMessage: $errorMessage, metrics: $metrics)';
  }
}

/// @nodoc
abstract mixin class _$HomeMetricsStateCopyWith<$Res>
    implements $HomeMetricsStateCopyWith<$Res> {
  factory _$HomeMetricsStateCopyWith(
          _HomeMetricsState value, $Res Function(_HomeMetricsState) _then) =
      __$HomeMetricsStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, String? errorMessage, HomeMetricsEntity? metrics});
}

/// @nodoc
class __$HomeMetricsStateCopyWithImpl<$Res>
    implements _$HomeMetricsStateCopyWith<$Res> {
  __$HomeMetricsStateCopyWithImpl(this._self, this._then);

  final _HomeMetricsState _self;
  final $Res Function(_HomeMetricsState) _then;

  /// Create a copy of HomeMetricsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? metrics = freezed,
  }) {
    return _then(_HomeMetricsState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      metrics: freezed == metrics
          ? _self.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as HomeMetricsEntity?,
    ));
  }
}

// dart format on
