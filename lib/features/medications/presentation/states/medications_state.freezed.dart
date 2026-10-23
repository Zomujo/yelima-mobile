// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medications_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicationsState {
  MedicationAdherence? get adherence;
  MedicationCount? get counts;
  Map<MedicationSection, List<MedicationEntity>> get doses;
  Set<String> get confirmingMedicationIds;
  MedicationSection get section;

  /// Create a copy of MedicationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MedicationsStateCopyWith<MedicationsState> get copyWith =>
      _$MedicationsStateCopyWithImpl<MedicationsState>(
          this as MedicationsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MedicationsState &&
            (identical(other.adherence, adherence) ||
                other.adherence == adherence) &&
            (identical(other.counts, counts) || other.counts == counts) &&
            const DeepCollectionEquality().equals(other.doses, doses) &&
            const DeepCollectionEquality().equals(
                other.confirmingMedicationIds, confirmingMedicationIds) &&
            (identical(other.section, section) || other.section == section));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      adherence,
      counts,
      const DeepCollectionEquality().hash(doses),
      const DeepCollectionEquality().hash(confirmingMedicationIds),
      section);

  @override
  String toString() {
    return 'MedicationsState(adherence: $adherence, counts: $counts, doses: $doses, confirmingMedicationIds: $confirmingMedicationIds, section: $section)';
  }
}

/// @nodoc
abstract mixin class $MedicationsStateCopyWith<$Res> {
  factory $MedicationsStateCopyWith(
          MedicationsState value, $Res Function(MedicationsState) _then) =
      _$MedicationsStateCopyWithImpl;
  @useResult
  $Res call(
      {MedicationAdherence? adherence,
      MedicationCount? counts,
      Map<MedicationSection, List<MedicationEntity>> doses,
      Set<String> confirmingMedicationIds,
      MedicationSection section});
}

/// @nodoc
class _$MedicationsStateCopyWithImpl<$Res>
    implements $MedicationsStateCopyWith<$Res> {
  _$MedicationsStateCopyWithImpl(this._self, this._then);

  final MedicationsState _self;
  final $Res Function(MedicationsState) _then;

  /// Create a copy of MedicationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? adherence = freezed,
    Object? counts = freezed,
    Object? doses = null,
    Object? confirmingMedicationIds = null,
    Object? section = null,
  }) {
    return _then(_self.copyWith(
      adherence: freezed == adherence
          ? _self.adherence
          : adherence // ignore: cast_nullable_to_non_nullable
              as MedicationAdherence?,
      counts: freezed == counts
          ? _self.counts
          : counts // ignore: cast_nullable_to_non_nullable
              as MedicationCount?,
      doses: null == doses
          ? _self.doses
          : doses // ignore: cast_nullable_to_non_nullable
              as Map<MedicationSection, List<MedicationEntity>>,
      confirmingMedicationIds: null == confirmingMedicationIds
          ? _self.confirmingMedicationIds
          : confirmingMedicationIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      section: null == section
          ? _self.section
          : section // ignore: cast_nullable_to_non_nullable
              as MedicationSection,
    ));
  }
}

/// @nodoc

class _MedicationsState implements MedicationsState {
  const _MedicationsState(
      {this.adherence,
      this.counts,
      final Map<MedicationSection, List<MedicationEntity>> doses = const {},
      final Set<String> confirmingMedicationIds = const {},
      this.section = MedicationSection.morning})
      : _doses = doses,
        _confirmingMedicationIds = confirmingMedicationIds;

  @override
  final MedicationAdherence? adherence;
  @override
  final MedicationCount? counts;
  final Map<MedicationSection, List<MedicationEntity>> _doses;
  @override
  @JsonKey()
  Map<MedicationSection, List<MedicationEntity>> get doses {
    if (_doses is EqualUnmodifiableMapView) return _doses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_doses);
  }

  final Set<String> _confirmingMedicationIds;
  @override
  @JsonKey()
  Set<String> get confirmingMedicationIds {
    if (_confirmingMedicationIds is EqualUnmodifiableSetView)
      return _confirmingMedicationIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_confirmingMedicationIds);
  }

  @override
  @JsonKey()
  final MedicationSection section;

  /// Create a copy of MedicationsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MedicationsStateCopyWith<_MedicationsState> get copyWith =>
      __$MedicationsStateCopyWithImpl<_MedicationsState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MedicationsState &&
            (identical(other.adherence, adherence) ||
                other.adherence == adherence) &&
            (identical(other.counts, counts) || other.counts == counts) &&
            const DeepCollectionEquality().equals(other._doses, _doses) &&
            const DeepCollectionEquality().equals(
                other._confirmingMedicationIds, _confirmingMedicationIds) &&
            (identical(other.section, section) || other.section == section));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      adherence,
      counts,
      const DeepCollectionEquality().hash(_doses),
      const DeepCollectionEquality().hash(_confirmingMedicationIds),
      section);

  @override
  String toString() {
    return 'MedicationsState(adherence: $adherence, counts: $counts, doses: $doses, confirmingMedicationIds: $confirmingMedicationIds, section: $section)';
  }
}

/// @nodoc
abstract mixin class _$MedicationsStateCopyWith<$Res>
    implements $MedicationsStateCopyWith<$Res> {
  factory _$MedicationsStateCopyWith(
          _MedicationsState value, $Res Function(_MedicationsState) _then) =
      __$MedicationsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {MedicationAdherence? adherence,
      MedicationCount? counts,
      Map<MedicationSection, List<MedicationEntity>> doses,
      Set<String> confirmingMedicationIds,
      MedicationSection section});
}

/// @nodoc
class __$MedicationsStateCopyWithImpl<$Res>
    implements _$MedicationsStateCopyWith<$Res> {
  __$MedicationsStateCopyWithImpl(this._self, this._then);

  final _MedicationsState _self;
  final $Res Function(_MedicationsState) _then;

  /// Create a copy of MedicationsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? adherence = freezed,
    Object? counts = freezed,
    Object? doses = null,
    Object? confirmingMedicationIds = null,
    Object? section = null,
  }) {
    return _then(_MedicationsState(
      adherence: freezed == adherence
          ? _self.adherence
          : adherence // ignore: cast_nullable_to_non_nullable
              as MedicationAdherence?,
      counts: freezed == counts
          ? _self.counts
          : counts // ignore: cast_nullable_to_non_nullable
              as MedicationCount?,
      doses: null == doses
          ? _self._doses
          : doses // ignore: cast_nullable_to_non_nullable
              as Map<MedicationSection, List<MedicationEntity>>,
      confirmingMedicationIds: null == confirmingMedicationIds
          ? _self._confirmingMedicationIds
          : confirmingMedicationIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      section: null == section
          ? _self.section
          : section // ignore: cast_nullable_to_non_nullable
              as MedicationSection,
    ));
  }
}

// dart format on
