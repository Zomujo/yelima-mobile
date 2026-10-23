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
  /// Null until the phone's readings have loaded.
  LatestVitals? get vitals;

  /// Fraction of doses taken this week (0–1), or null if unknown.
  double? get adherence;

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
            (identical(other.vitals, vitals) || other.vitals == vitals) &&
            (identical(other.adherence, adherence) ||
                other.adherence == adherence));
  }

  @override
  int get hashCode => Object.hash(runtimeType, vitals, adherence);

  @override
  String toString() {
    return 'HomeMetricsState(vitals: $vitals, adherence: $adherence)';
  }
}

/// @nodoc
abstract mixin class $HomeMetricsStateCopyWith<$Res> {
  factory $HomeMetricsStateCopyWith(
          HomeMetricsState value, $Res Function(HomeMetricsState) _then) =
      _$HomeMetricsStateCopyWithImpl;
  @useResult
  $Res call({LatestVitals? vitals, double? adherence});
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
    Object? vitals = freezed,
    Object? adherence = freezed,
  }) {
    return _then(_self.copyWith(
      vitals: freezed == vitals
          ? _self.vitals
          : vitals // ignore: cast_nullable_to_non_nullable
              as LatestVitals?,
      adherence: freezed == adherence
          ? _self.adherence
          : adherence // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _HomeMetricsState implements HomeMetricsState {
  const _HomeMetricsState({this.vitals, this.adherence});

  /// Null until the phone's readings have loaded.
  @override
  final LatestVitals? vitals;

  /// Fraction of doses taken this week (0–1), or null if unknown.
  @override
  final double? adherence;

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
            (identical(other.vitals, vitals) || other.vitals == vitals) &&
            (identical(other.adherence, adherence) ||
                other.adherence == adherence));
  }

  @override
  int get hashCode => Object.hash(runtimeType, vitals, adherence);

  @override
  String toString() {
    return 'HomeMetricsState(vitals: $vitals, adherence: $adherence)';
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
  $Res call({LatestVitals? vitals, double? adherence});
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
    Object? vitals = freezed,
    Object? adherence = freezed,
  }) {
    return _then(_HomeMetricsState(
      vitals: freezed == vitals
          ? _self.vitals
          : vitals // ignore: cast_nullable_to_non_nullable
              as LatestVitals?,
      adherence: freezed == adherence
          ? _self.adherence
          : adherence // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
