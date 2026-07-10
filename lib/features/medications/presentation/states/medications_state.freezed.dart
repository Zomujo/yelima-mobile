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
  Map<String, List<MedicationEntity>> get medicationsBySection;
  bool get isAdherenceLoading;
  bool get isCountsLoading;
  Map<String, bool> get sectionLoadingStatus;
  String? get adherenceError;
  String? get countsError;
  Map<String, String> get sectionErrors;
  String? get confirmingMedicationId;
  int get selectedTabIndex;

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
            const DeepCollectionEquality()
                .equals(other.medicationsBySection, medicationsBySection) &&
            (identical(other.isAdherenceLoading, isAdherenceLoading) ||
                other.isAdherenceLoading == isAdherenceLoading) &&
            (identical(other.isCountsLoading, isCountsLoading) ||
                other.isCountsLoading == isCountsLoading) &&
            const DeepCollectionEquality()
                .equals(other.sectionLoadingStatus, sectionLoadingStatus) &&
            (identical(other.adherenceError, adherenceError) ||
                other.adherenceError == adherenceError) &&
            (identical(other.countsError, countsError) ||
                other.countsError == countsError) &&
            const DeepCollectionEquality()
                .equals(other.sectionErrors, sectionErrors) &&
            (identical(other.confirmingMedicationId, confirmingMedicationId) ||
                other.confirmingMedicationId == confirmingMedicationId) &&
            (identical(other.selectedTabIndex, selectedTabIndex) ||
                other.selectedTabIndex == selectedTabIndex));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      adherence,
      counts,
      const DeepCollectionEquality().hash(medicationsBySection),
      isAdherenceLoading,
      isCountsLoading,
      const DeepCollectionEquality().hash(sectionLoadingStatus),
      adherenceError,
      countsError,
      const DeepCollectionEquality().hash(sectionErrors),
      confirmingMedicationId,
      selectedTabIndex);

  @override
  String toString() {
    return 'MedicationsState(adherence: $adherence, counts: $counts, medicationsBySection: $medicationsBySection, isAdherenceLoading: $isAdherenceLoading, isCountsLoading: $isCountsLoading, sectionLoadingStatus: $sectionLoadingStatus, adherenceError: $adherenceError, countsError: $countsError, sectionErrors: $sectionErrors, confirmingMedicationId: $confirmingMedicationId, selectedTabIndex: $selectedTabIndex)';
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
      Map<String, List<MedicationEntity>> medicationsBySection,
      bool isAdherenceLoading,
      bool isCountsLoading,
      Map<String, bool> sectionLoadingStatus,
      String? adherenceError,
      String? countsError,
      Map<String, String> sectionErrors,
      String? confirmingMedicationId,
      int selectedTabIndex});
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
    Object? medicationsBySection = null,
    Object? isAdherenceLoading = null,
    Object? isCountsLoading = null,
    Object? sectionLoadingStatus = null,
    Object? adherenceError = freezed,
    Object? countsError = freezed,
    Object? sectionErrors = null,
    Object? confirmingMedicationId = freezed,
    Object? selectedTabIndex = null,
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
      medicationsBySection: null == medicationsBySection
          ? _self.medicationsBySection
          : medicationsBySection // ignore: cast_nullable_to_non_nullable
              as Map<String, List<MedicationEntity>>,
      isAdherenceLoading: null == isAdherenceLoading
          ? _self.isAdherenceLoading
          : isAdherenceLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCountsLoading: null == isCountsLoading
          ? _self.isCountsLoading
          : isCountsLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      sectionLoadingStatus: null == sectionLoadingStatus
          ? _self.sectionLoadingStatus
          : sectionLoadingStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      adherenceError: freezed == adherenceError
          ? _self.adherenceError
          : adherenceError // ignore: cast_nullable_to_non_nullable
              as String?,
      countsError: freezed == countsError
          ? _self.countsError
          : countsError // ignore: cast_nullable_to_non_nullable
              as String?,
      sectionErrors: null == sectionErrors
          ? _self.sectionErrors
          : sectionErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      confirmingMedicationId: freezed == confirmingMedicationId
          ? _self.confirmingMedicationId
          : confirmingMedicationId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedTabIndex: null == selectedTabIndex
          ? _self.selectedTabIndex
          : selectedTabIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _MedicationsState implements MedicationsState {
  const _MedicationsState(
      {this.adherence,
      this.counts,
      final Map<String, List<MedicationEntity>> medicationsBySection = const {},
      this.isAdherenceLoading = false,
      this.isCountsLoading = false,
      final Map<String, bool> sectionLoadingStatus = const {},
      this.adherenceError,
      this.countsError,
      final Map<String, String> sectionErrors = const {},
      this.confirmingMedicationId,
      this.selectedTabIndex = 0})
      : _medicationsBySection = medicationsBySection,
        _sectionLoadingStatus = sectionLoadingStatus,
        _sectionErrors = sectionErrors;

  @override
  final MedicationAdherence? adherence;
  @override
  final MedicationCount? counts;
  final Map<String, List<MedicationEntity>> _medicationsBySection;
  @override
  @JsonKey()
  Map<String, List<MedicationEntity>> get medicationsBySection {
    if (_medicationsBySection is EqualUnmodifiableMapView)
      return _medicationsBySection;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_medicationsBySection);
  }

  @override
  @JsonKey()
  final bool isAdherenceLoading;
  @override
  @JsonKey()
  final bool isCountsLoading;
  final Map<String, bool> _sectionLoadingStatus;
  @override
  @JsonKey()
  Map<String, bool> get sectionLoadingStatus {
    if (_sectionLoadingStatus is EqualUnmodifiableMapView)
      return _sectionLoadingStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sectionLoadingStatus);
  }

  @override
  final String? adherenceError;
  @override
  final String? countsError;
  final Map<String, String> _sectionErrors;
  @override
  @JsonKey()
  Map<String, String> get sectionErrors {
    if (_sectionErrors is EqualUnmodifiableMapView) return _sectionErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sectionErrors);
  }

  @override
  final String? confirmingMedicationId;
  @override
  @JsonKey()
  final int selectedTabIndex;

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
            const DeepCollectionEquality()
                .equals(other._medicationsBySection, _medicationsBySection) &&
            (identical(other.isAdherenceLoading, isAdherenceLoading) ||
                other.isAdherenceLoading == isAdherenceLoading) &&
            (identical(other.isCountsLoading, isCountsLoading) ||
                other.isCountsLoading == isCountsLoading) &&
            const DeepCollectionEquality()
                .equals(other._sectionLoadingStatus, _sectionLoadingStatus) &&
            (identical(other.adherenceError, adherenceError) ||
                other.adherenceError == adherenceError) &&
            (identical(other.countsError, countsError) ||
                other.countsError == countsError) &&
            const DeepCollectionEquality()
                .equals(other._sectionErrors, _sectionErrors) &&
            (identical(other.confirmingMedicationId, confirmingMedicationId) ||
                other.confirmingMedicationId == confirmingMedicationId) &&
            (identical(other.selectedTabIndex, selectedTabIndex) ||
                other.selectedTabIndex == selectedTabIndex));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      adherence,
      counts,
      const DeepCollectionEquality().hash(_medicationsBySection),
      isAdherenceLoading,
      isCountsLoading,
      const DeepCollectionEquality().hash(_sectionLoadingStatus),
      adherenceError,
      countsError,
      const DeepCollectionEquality().hash(_sectionErrors),
      confirmingMedicationId,
      selectedTabIndex);

  @override
  String toString() {
    return 'MedicationsState(adherence: $adherence, counts: $counts, medicationsBySection: $medicationsBySection, isAdherenceLoading: $isAdherenceLoading, isCountsLoading: $isCountsLoading, sectionLoadingStatus: $sectionLoadingStatus, adherenceError: $adherenceError, countsError: $countsError, sectionErrors: $sectionErrors, confirmingMedicationId: $confirmingMedicationId, selectedTabIndex: $selectedTabIndex)';
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
      Map<String, List<MedicationEntity>> medicationsBySection,
      bool isAdherenceLoading,
      bool isCountsLoading,
      Map<String, bool> sectionLoadingStatus,
      String? adherenceError,
      String? countsError,
      Map<String, String> sectionErrors,
      String? confirmingMedicationId,
      int selectedTabIndex});
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
    Object? medicationsBySection = null,
    Object? isAdherenceLoading = null,
    Object? isCountsLoading = null,
    Object? sectionLoadingStatus = null,
    Object? adherenceError = freezed,
    Object? countsError = freezed,
    Object? sectionErrors = null,
    Object? confirmingMedicationId = freezed,
    Object? selectedTabIndex = null,
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
      medicationsBySection: null == medicationsBySection
          ? _self._medicationsBySection
          : medicationsBySection // ignore: cast_nullable_to_non_nullable
              as Map<String, List<MedicationEntity>>,
      isAdherenceLoading: null == isAdherenceLoading
          ? _self.isAdherenceLoading
          : isAdherenceLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCountsLoading: null == isCountsLoading
          ? _self.isCountsLoading
          : isCountsLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      sectionLoadingStatus: null == sectionLoadingStatus
          ? _self._sectionLoadingStatus
          : sectionLoadingStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      adherenceError: freezed == adherenceError
          ? _self.adherenceError
          : adherenceError // ignore: cast_nullable_to_non_nullable
              as String?,
      countsError: freezed == countsError
          ? _self.countsError
          : countsError // ignore: cast_nullable_to_non_nullable
              as String?,
      sectionErrors: null == sectionErrors
          ? _self._sectionErrors
          : sectionErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      confirmingMedicationId: freezed == confirmingMedicationId
          ? _self.confirmingMedicationId
          : confirmingMedicationId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedTabIndex: null == selectedTabIndex
          ? _self.selectedTabIndex
          : selectedTabIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
