// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_medication_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddMedicationFormState {
  String get selectedUnit;
  SeededMedicationModel? get selectedPreloadedMedication;
  bool get hasMorning;
  TimeOfDay get morningTime;
  int get morningQuantity;
  bool get hasAfternoon;
  TimeOfDay get afternoonTime;
  int get afternoonQuantity;
  bool get hasEvening;
  TimeOfDay get eveningTime;
  int get eveningQuantity;

  /// Create a copy of AddMedicationFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AddMedicationFormStateCopyWith<AddMedicationFormState> get copyWith =>
      _$AddMedicationFormStateCopyWithImpl<AddMedicationFormState>(
          this as AddMedicationFormState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AddMedicationFormState &&
            (identical(other.selectedUnit, selectedUnit) ||
                other.selectedUnit == selectedUnit) &&
            (identical(other.selectedPreloadedMedication,
                    selectedPreloadedMedication) ||
                other.selectedPreloadedMedication ==
                    selectedPreloadedMedication) &&
            (identical(other.hasMorning, hasMorning) ||
                other.hasMorning == hasMorning) &&
            (identical(other.morningTime, morningTime) ||
                other.morningTime == morningTime) &&
            (identical(other.morningQuantity, morningQuantity) ||
                other.morningQuantity == morningQuantity) &&
            (identical(other.hasAfternoon, hasAfternoon) ||
                other.hasAfternoon == hasAfternoon) &&
            (identical(other.afternoonTime, afternoonTime) ||
                other.afternoonTime == afternoonTime) &&
            (identical(other.afternoonQuantity, afternoonQuantity) ||
                other.afternoonQuantity == afternoonQuantity) &&
            (identical(other.hasEvening, hasEvening) ||
                other.hasEvening == hasEvening) &&
            (identical(other.eveningTime, eveningTime) ||
                other.eveningTime == eveningTime) &&
            (identical(other.eveningQuantity, eveningQuantity) ||
                other.eveningQuantity == eveningQuantity));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedUnit,
      selectedPreloadedMedication,
      hasMorning,
      morningTime,
      morningQuantity,
      hasAfternoon,
      afternoonTime,
      afternoonQuantity,
      hasEvening,
      eveningTime,
      eveningQuantity);

  @override
  String toString() {
    return 'AddMedicationFormState(selectedUnit: $selectedUnit, selectedPreloadedMedication: $selectedPreloadedMedication, hasMorning: $hasMorning, morningTime: $morningTime, morningQuantity: $morningQuantity, hasAfternoon: $hasAfternoon, afternoonTime: $afternoonTime, afternoonQuantity: $afternoonQuantity, hasEvening: $hasEvening, eveningTime: $eveningTime, eveningQuantity: $eveningQuantity)';
  }
}

/// @nodoc
abstract mixin class $AddMedicationFormStateCopyWith<$Res> {
  factory $AddMedicationFormStateCopyWith(AddMedicationFormState value,
          $Res Function(AddMedicationFormState) _then) =
      _$AddMedicationFormStateCopyWithImpl;
  @useResult
  $Res call(
      {String selectedUnit,
      SeededMedicationModel? selectedPreloadedMedication,
      bool hasMorning,
      TimeOfDay morningTime,
      int morningQuantity,
      bool hasAfternoon,
      TimeOfDay afternoonTime,
      int afternoonQuantity,
      bool hasEvening,
      TimeOfDay eveningTime,
      int eveningQuantity});

  $SeededMedicationModelCopyWith<$Res>? get selectedPreloadedMedication;
}

/// @nodoc
class _$AddMedicationFormStateCopyWithImpl<$Res>
    implements $AddMedicationFormStateCopyWith<$Res> {
  _$AddMedicationFormStateCopyWithImpl(this._self, this._then);

  final AddMedicationFormState _self;
  final $Res Function(AddMedicationFormState) _then;

  /// Create a copy of AddMedicationFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedUnit = null,
    Object? selectedPreloadedMedication = freezed,
    Object? hasMorning = null,
    Object? morningTime = null,
    Object? morningQuantity = null,
    Object? hasAfternoon = null,
    Object? afternoonTime = null,
    Object? afternoonQuantity = null,
    Object? hasEvening = null,
    Object? eveningTime = null,
    Object? eveningQuantity = null,
  }) {
    return _then(_self.copyWith(
      selectedUnit: null == selectedUnit
          ? _self.selectedUnit
          : selectedUnit // ignore: cast_nullable_to_non_nullable
              as String,
      selectedPreloadedMedication: freezed == selectedPreloadedMedication
          ? _self.selectedPreloadedMedication
          : selectedPreloadedMedication // ignore: cast_nullable_to_non_nullable
              as SeededMedicationModel?,
      hasMorning: null == hasMorning
          ? _self.hasMorning
          : hasMorning // ignore: cast_nullable_to_non_nullable
              as bool,
      morningTime: null == morningTime
          ? _self.morningTime
          : morningTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      morningQuantity: null == morningQuantity
          ? _self.morningQuantity
          : morningQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      hasAfternoon: null == hasAfternoon
          ? _self.hasAfternoon
          : hasAfternoon // ignore: cast_nullable_to_non_nullable
              as bool,
      afternoonTime: null == afternoonTime
          ? _self.afternoonTime
          : afternoonTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      afternoonQuantity: null == afternoonQuantity
          ? _self.afternoonQuantity
          : afternoonQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      hasEvening: null == hasEvening
          ? _self.hasEvening
          : hasEvening // ignore: cast_nullable_to_non_nullable
              as bool,
      eveningTime: null == eveningTime
          ? _self.eveningTime
          : eveningTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      eveningQuantity: null == eveningQuantity
          ? _self.eveningQuantity
          : eveningQuantity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of AddMedicationFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SeededMedicationModelCopyWith<$Res>? get selectedPreloadedMedication {
    if (_self.selectedPreloadedMedication == null) {
      return null;
    }

    return $SeededMedicationModelCopyWith<$Res>(
        _self.selectedPreloadedMedication!, (value) {
      return _then(_self.copyWith(selectedPreloadedMedication: value));
    });
  }
}

/// @nodoc

class _AddMedicationFormState implements AddMedicationFormState {
  const _AddMedicationFormState(
      {this.selectedUnit = 'tablet',
      this.selectedPreloadedMedication,
      this.hasMorning = false,
      this.morningTime = const TimeOfDay(hour: 8, minute: 0),
      this.morningQuantity = 1,
      this.hasAfternoon = false,
      this.afternoonTime = const TimeOfDay(hour: 13, minute: 0),
      this.afternoonQuantity = 1,
      this.hasEvening = false,
      this.eveningTime = const TimeOfDay(hour: 20, minute: 0),
      this.eveningQuantity = 1});

  @override
  @JsonKey()
  final String selectedUnit;
  @override
  final SeededMedicationModel? selectedPreloadedMedication;
  @override
  @JsonKey()
  final bool hasMorning;
  @override
  @JsonKey()
  final TimeOfDay morningTime;
  @override
  @JsonKey()
  final int morningQuantity;
  @override
  @JsonKey()
  final bool hasAfternoon;
  @override
  @JsonKey()
  final TimeOfDay afternoonTime;
  @override
  @JsonKey()
  final int afternoonQuantity;
  @override
  @JsonKey()
  final bool hasEvening;
  @override
  @JsonKey()
  final TimeOfDay eveningTime;
  @override
  @JsonKey()
  final int eveningQuantity;

  /// Create a copy of AddMedicationFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddMedicationFormStateCopyWith<_AddMedicationFormState> get copyWith =>
      __$AddMedicationFormStateCopyWithImpl<_AddMedicationFormState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddMedicationFormState &&
            (identical(other.selectedUnit, selectedUnit) ||
                other.selectedUnit == selectedUnit) &&
            (identical(other.selectedPreloadedMedication,
                    selectedPreloadedMedication) ||
                other.selectedPreloadedMedication ==
                    selectedPreloadedMedication) &&
            (identical(other.hasMorning, hasMorning) ||
                other.hasMorning == hasMorning) &&
            (identical(other.morningTime, morningTime) ||
                other.morningTime == morningTime) &&
            (identical(other.morningQuantity, morningQuantity) ||
                other.morningQuantity == morningQuantity) &&
            (identical(other.hasAfternoon, hasAfternoon) ||
                other.hasAfternoon == hasAfternoon) &&
            (identical(other.afternoonTime, afternoonTime) ||
                other.afternoonTime == afternoonTime) &&
            (identical(other.afternoonQuantity, afternoonQuantity) ||
                other.afternoonQuantity == afternoonQuantity) &&
            (identical(other.hasEvening, hasEvening) ||
                other.hasEvening == hasEvening) &&
            (identical(other.eveningTime, eveningTime) ||
                other.eveningTime == eveningTime) &&
            (identical(other.eveningQuantity, eveningQuantity) ||
                other.eveningQuantity == eveningQuantity));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedUnit,
      selectedPreloadedMedication,
      hasMorning,
      morningTime,
      morningQuantity,
      hasAfternoon,
      afternoonTime,
      afternoonQuantity,
      hasEvening,
      eveningTime,
      eveningQuantity);

  @override
  String toString() {
    return 'AddMedicationFormState(selectedUnit: $selectedUnit, selectedPreloadedMedication: $selectedPreloadedMedication, hasMorning: $hasMorning, morningTime: $morningTime, morningQuantity: $morningQuantity, hasAfternoon: $hasAfternoon, afternoonTime: $afternoonTime, afternoonQuantity: $afternoonQuantity, hasEvening: $hasEvening, eveningTime: $eveningTime, eveningQuantity: $eveningQuantity)';
  }
}

/// @nodoc
abstract mixin class _$AddMedicationFormStateCopyWith<$Res>
    implements $AddMedicationFormStateCopyWith<$Res> {
  factory _$AddMedicationFormStateCopyWith(_AddMedicationFormState value,
          $Res Function(_AddMedicationFormState) _then) =
      __$AddMedicationFormStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String selectedUnit,
      SeededMedicationModel? selectedPreloadedMedication,
      bool hasMorning,
      TimeOfDay morningTime,
      int morningQuantity,
      bool hasAfternoon,
      TimeOfDay afternoonTime,
      int afternoonQuantity,
      bool hasEvening,
      TimeOfDay eveningTime,
      int eveningQuantity});

  @override
  $SeededMedicationModelCopyWith<$Res>? get selectedPreloadedMedication;
}

/// @nodoc
class __$AddMedicationFormStateCopyWithImpl<$Res>
    implements _$AddMedicationFormStateCopyWith<$Res> {
  __$AddMedicationFormStateCopyWithImpl(this._self, this._then);

  final _AddMedicationFormState _self;
  final $Res Function(_AddMedicationFormState) _then;

  /// Create a copy of AddMedicationFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? selectedUnit = null,
    Object? selectedPreloadedMedication = freezed,
    Object? hasMorning = null,
    Object? morningTime = null,
    Object? morningQuantity = null,
    Object? hasAfternoon = null,
    Object? afternoonTime = null,
    Object? afternoonQuantity = null,
    Object? hasEvening = null,
    Object? eveningTime = null,
    Object? eveningQuantity = null,
  }) {
    return _then(_AddMedicationFormState(
      selectedUnit: null == selectedUnit
          ? _self.selectedUnit
          : selectedUnit // ignore: cast_nullable_to_non_nullable
              as String,
      selectedPreloadedMedication: freezed == selectedPreloadedMedication
          ? _self.selectedPreloadedMedication
          : selectedPreloadedMedication // ignore: cast_nullable_to_non_nullable
              as SeededMedicationModel?,
      hasMorning: null == hasMorning
          ? _self.hasMorning
          : hasMorning // ignore: cast_nullable_to_non_nullable
              as bool,
      morningTime: null == morningTime
          ? _self.morningTime
          : morningTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      morningQuantity: null == morningQuantity
          ? _self.morningQuantity
          : morningQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      hasAfternoon: null == hasAfternoon
          ? _self.hasAfternoon
          : hasAfternoon // ignore: cast_nullable_to_non_nullable
              as bool,
      afternoonTime: null == afternoonTime
          ? _self.afternoonTime
          : afternoonTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      afternoonQuantity: null == afternoonQuantity
          ? _self.afternoonQuantity
          : afternoonQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      hasEvening: null == hasEvening
          ? _self.hasEvening
          : hasEvening // ignore: cast_nullable_to_non_nullable
              as bool,
      eveningTime: null == eveningTime
          ? _self.eveningTime
          : eveningTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      eveningQuantity: null == eveningQuantity
          ? _self.eveningQuantity
          : eveningQuantity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of AddMedicationFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SeededMedicationModelCopyWith<$Res>? get selectedPreloadedMedication {
    if (_self.selectedPreloadedMedication == null) {
      return null;
    }

    return $SeededMedicationModelCopyWith<$Res>(
        _self.selectedPreloadedMedication!, (value) {
      return _then(_self.copyWith(selectedPreloadedMedication: value));
    });
  }
}

// dart format on
