// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_logging_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingLoggingState {
  int get selectedTypeIndex;
  String get vitalSubType;
  int get systolic;
  int get diastolic;
  double get sugarLevel;
  DateTime get selectedDate;
  bool get hasChanged;
  bool get isSaving;
  bool get isInitializing;

  /// Create a copy of ReadingLoggingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReadingLoggingStateCopyWith<ReadingLoggingState> get copyWith =>
      _$ReadingLoggingStateCopyWithImpl<ReadingLoggingState>(
          this as ReadingLoggingState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReadingLoggingState &&
            (identical(other.selectedTypeIndex, selectedTypeIndex) ||
                other.selectedTypeIndex == selectedTypeIndex) &&
            (identical(other.vitalSubType, vitalSubType) ||
                other.vitalSubType == vitalSubType) &&
            (identical(other.systolic, systolic) ||
                other.systolic == systolic) &&
            (identical(other.diastolic, diastolic) ||
                other.diastolic == diastolic) &&
            (identical(other.sugarLevel, sugarLevel) ||
                other.sugarLevel == sugarLevel) &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            (identical(other.hasChanged, hasChanged) ||
                other.hasChanged == hasChanged) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.isInitializing, isInitializing) ||
                other.isInitializing == isInitializing));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedTypeIndex,
      vitalSubType,
      systolic,
      diastolic,
      sugarLevel,
      selectedDate,
      hasChanged,
      isSaving,
      isInitializing);

  @override
  String toString() {
    return 'ReadingLoggingState(selectedTypeIndex: $selectedTypeIndex, vitalSubType: $vitalSubType, systolic: $systolic, diastolic: $diastolic, sugarLevel: $sugarLevel, selectedDate: $selectedDate, hasChanged: $hasChanged, isSaving: $isSaving, isInitializing: $isInitializing)';
  }
}

/// @nodoc
abstract mixin class $ReadingLoggingStateCopyWith<$Res> {
  factory $ReadingLoggingStateCopyWith(
          ReadingLoggingState value, $Res Function(ReadingLoggingState) _then) =
      _$ReadingLoggingStateCopyWithImpl;
  @useResult
  $Res call(
      {int selectedTypeIndex,
      String vitalSubType,
      int systolic,
      int diastolic,
      double sugarLevel,
      DateTime selectedDate,
      bool hasChanged,
      bool isSaving,
      bool isInitializing});
}

/// @nodoc
class _$ReadingLoggingStateCopyWithImpl<$Res>
    implements $ReadingLoggingStateCopyWith<$Res> {
  _$ReadingLoggingStateCopyWithImpl(this._self, this._then);

  final ReadingLoggingState _self;
  final $Res Function(ReadingLoggingState) _then;

  /// Create a copy of ReadingLoggingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedTypeIndex = null,
    Object? vitalSubType = null,
    Object? systolic = null,
    Object? diastolic = null,
    Object? sugarLevel = null,
    Object? selectedDate = null,
    Object? hasChanged = null,
    Object? isSaving = null,
    Object? isInitializing = null,
  }) {
    return _then(_self.copyWith(
      selectedTypeIndex: null == selectedTypeIndex
          ? _self.selectedTypeIndex
          : selectedTypeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      vitalSubType: null == vitalSubType
          ? _self.vitalSubType
          : vitalSubType // ignore: cast_nullable_to_non_nullable
              as String,
      systolic: null == systolic
          ? _self.systolic
          : systolic // ignore: cast_nullable_to_non_nullable
              as int,
      diastolic: null == diastolic
          ? _self.diastolic
          : diastolic // ignore: cast_nullable_to_non_nullable
              as int,
      sugarLevel: null == sugarLevel
          ? _self.sugarLevel
          : sugarLevel // ignore: cast_nullable_to_non_nullable
              as double,
      selectedDate: null == selectedDate
          ? _self.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hasChanged: null == hasChanged
          ? _self.hasChanged
          : hasChanged // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _self.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitializing: null == isInitializing
          ? _self.isInitializing
          : isInitializing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _ReadingLoggingState implements ReadingLoggingState {
  const _ReadingLoggingState(
      {this.selectedTypeIndex = 0,
      this.vitalSubType = 'fasting',
      this.systolic = 120,
      this.diastolic = 80,
      this.sugarLevel = 5.5,
      required this.selectedDate,
      this.hasChanged = false,
      this.isSaving = false,
      this.isInitializing = true});

  @override
  @JsonKey()
  final int selectedTypeIndex;
  @override
  @JsonKey()
  final String vitalSubType;
  @override
  @JsonKey()
  final int systolic;
  @override
  @JsonKey()
  final int diastolic;
  @override
  @JsonKey()
  final double sugarLevel;
  @override
  final DateTime selectedDate;
  @override
  @JsonKey()
  final bool hasChanged;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  @JsonKey()
  final bool isInitializing;

  /// Create a copy of ReadingLoggingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReadingLoggingStateCopyWith<_ReadingLoggingState> get copyWith =>
      __$ReadingLoggingStateCopyWithImpl<_ReadingLoggingState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReadingLoggingState &&
            (identical(other.selectedTypeIndex, selectedTypeIndex) ||
                other.selectedTypeIndex == selectedTypeIndex) &&
            (identical(other.vitalSubType, vitalSubType) ||
                other.vitalSubType == vitalSubType) &&
            (identical(other.systolic, systolic) ||
                other.systolic == systolic) &&
            (identical(other.diastolic, diastolic) ||
                other.diastolic == diastolic) &&
            (identical(other.sugarLevel, sugarLevel) ||
                other.sugarLevel == sugarLevel) &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            (identical(other.hasChanged, hasChanged) ||
                other.hasChanged == hasChanged) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.isInitializing, isInitializing) ||
                other.isInitializing == isInitializing));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedTypeIndex,
      vitalSubType,
      systolic,
      diastolic,
      sugarLevel,
      selectedDate,
      hasChanged,
      isSaving,
      isInitializing);

  @override
  String toString() {
    return 'ReadingLoggingState(selectedTypeIndex: $selectedTypeIndex, vitalSubType: $vitalSubType, systolic: $systolic, diastolic: $diastolic, sugarLevel: $sugarLevel, selectedDate: $selectedDate, hasChanged: $hasChanged, isSaving: $isSaving, isInitializing: $isInitializing)';
  }
}

/// @nodoc
abstract mixin class _$ReadingLoggingStateCopyWith<$Res>
    implements $ReadingLoggingStateCopyWith<$Res> {
  factory _$ReadingLoggingStateCopyWith(_ReadingLoggingState value,
          $Res Function(_ReadingLoggingState) _then) =
      __$ReadingLoggingStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int selectedTypeIndex,
      String vitalSubType,
      int systolic,
      int diastolic,
      double sugarLevel,
      DateTime selectedDate,
      bool hasChanged,
      bool isSaving,
      bool isInitializing});
}

/// @nodoc
class __$ReadingLoggingStateCopyWithImpl<$Res>
    implements _$ReadingLoggingStateCopyWith<$Res> {
  __$ReadingLoggingStateCopyWithImpl(this._self, this._then);

  final _ReadingLoggingState _self;
  final $Res Function(_ReadingLoggingState) _then;

  /// Create a copy of ReadingLoggingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? selectedTypeIndex = null,
    Object? vitalSubType = null,
    Object? systolic = null,
    Object? diastolic = null,
    Object? sugarLevel = null,
    Object? selectedDate = null,
    Object? hasChanged = null,
    Object? isSaving = null,
    Object? isInitializing = null,
  }) {
    return _then(_ReadingLoggingState(
      selectedTypeIndex: null == selectedTypeIndex
          ? _self.selectedTypeIndex
          : selectedTypeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      vitalSubType: null == vitalSubType
          ? _self.vitalSubType
          : vitalSubType // ignore: cast_nullable_to_non_nullable
              as String,
      systolic: null == systolic
          ? _self.systolic
          : systolic // ignore: cast_nullable_to_non_nullable
              as int,
      diastolic: null == diastolic
          ? _self.diastolic
          : diastolic // ignore: cast_nullable_to_non_nullable
              as int,
      sugarLevel: null == sugarLevel
          ? _self.sugarLevel
          : sugarLevel // ignore: cast_nullable_to_non_nullable
              as double,
      selectedDate: null == selectedDate
          ? _self.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hasChanged: null == hasChanged
          ? _self.hasChanged
          : hasChanged // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _self.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitializing: null == isInitializing
          ? _self.isInitializing
          : isInitializing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
