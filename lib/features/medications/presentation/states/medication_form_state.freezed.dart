// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicationFormState {
  String get unit;
  bool get hasChanges;
  bool get isSaving;
  Map<MedicationSection, DoseSlot> get slots;

  /// Create a copy of MedicationFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MedicationFormStateCopyWith<MedicationFormState> get copyWith =>
      _$MedicationFormStateCopyWithImpl<MedicationFormState>(
          this as MedicationFormState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MedicationFormState &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.hasChanges, hasChanges) ||
                other.hasChanges == hasChanges) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            const DeepCollectionEquality().equals(other.slots, slots));
  }

  @override
  int get hashCode => Object.hash(runtimeType, unit, hasChanges, isSaving,
      const DeepCollectionEquality().hash(slots));

  @override
  String toString() {
    return 'MedicationFormState(unit: $unit, hasChanges: $hasChanges, isSaving: $isSaving, slots: $slots)';
  }
}

/// @nodoc
abstract mixin class $MedicationFormStateCopyWith<$Res> {
  factory $MedicationFormStateCopyWith(
          MedicationFormState value, $Res Function(MedicationFormState) _then) =
      _$MedicationFormStateCopyWithImpl;
  @useResult
  $Res call(
      {String unit,
      bool hasChanges,
      bool isSaving,
      Map<MedicationSection, DoseSlot> slots});
}

/// @nodoc
class _$MedicationFormStateCopyWithImpl<$Res>
    implements $MedicationFormStateCopyWith<$Res> {
  _$MedicationFormStateCopyWithImpl(this._self, this._then);

  final MedicationFormState _self;
  final $Res Function(MedicationFormState) _then;

  /// Create a copy of MedicationFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unit = null,
    Object? hasChanges = null,
    Object? isSaving = null,
    Object? slots = null,
  }) {
    return _then(_self.copyWith(
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      hasChanges: null == hasChanges
          ? _self.hasChanges
          : hasChanges // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _self.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      slots: null == slots
          ? _self.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as Map<MedicationSection, DoseSlot>,
    ));
  }
}

/// @nodoc

class _MedicationFormState implements MedicationFormState {
  const _MedicationFormState(
      {this.unit = 'tablet',
      this.hasChanges = false,
      this.isSaving = false,
      required final Map<MedicationSection, DoseSlot> slots})
      : _slots = slots;

  @override
  @JsonKey()
  final String unit;
  @override
  @JsonKey()
  final bool hasChanges;
  @override
  @JsonKey()
  final bool isSaving;
  final Map<MedicationSection, DoseSlot> _slots;
  @override
  Map<MedicationSection, DoseSlot> get slots {
    if (_slots is EqualUnmodifiableMapView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_slots);
  }

  /// Create a copy of MedicationFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MedicationFormStateCopyWith<_MedicationFormState> get copyWith =>
      __$MedicationFormStateCopyWithImpl<_MedicationFormState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MedicationFormState &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.hasChanges, hasChanges) ||
                other.hasChanges == hasChanges) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            const DeepCollectionEquality().equals(other._slots, _slots));
  }

  @override
  int get hashCode => Object.hash(runtimeType, unit, hasChanges, isSaving,
      const DeepCollectionEquality().hash(_slots));

  @override
  String toString() {
    return 'MedicationFormState(unit: $unit, hasChanges: $hasChanges, isSaving: $isSaving, slots: $slots)';
  }
}

/// @nodoc
abstract mixin class _$MedicationFormStateCopyWith<$Res>
    implements $MedicationFormStateCopyWith<$Res> {
  factory _$MedicationFormStateCopyWith(_MedicationFormState value,
          $Res Function(_MedicationFormState) _then) =
      __$MedicationFormStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String unit,
      bool hasChanges,
      bool isSaving,
      Map<MedicationSection, DoseSlot> slots});
}

/// @nodoc
class __$MedicationFormStateCopyWithImpl<$Res>
    implements _$MedicationFormStateCopyWith<$Res> {
  __$MedicationFormStateCopyWithImpl(this._self, this._then);

  final _MedicationFormState _self;
  final $Res Function(_MedicationFormState) _then;

  /// Create a copy of MedicationFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? unit = null,
    Object? hasChanges = null,
    Object? isSaving = null,
    Object? slots = null,
  }) {
    return _then(_MedicationFormState(
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      hasChanges: null == hasChanges
          ? _self.hasChanges
          : hasChanges // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _self.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      slots: null == slots
          ? _self._slots
          : slots // ignore: cast_nullable_to_non_nullable
              as Map<MedicationSection, DoseSlot>,
    ));
  }
}

/// @nodoc
mixin _$AddMedicationState {
  MedicationFormState get form;

  /// The preloaded medication picked from search, which suggests dosages.
  SeededMedicationModel? get picked;

  /// Create a copy of AddMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AddMedicationStateCopyWith<AddMedicationState> get copyWith =>
      _$AddMedicationStateCopyWithImpl<AddMedicationState>(
          this as AddMedicationState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AddMedicationState &&
            (identical(other.form, form) || other.form == form) &&
            (identical(other.picked, picked) || other.picked == picked));
  }

  @override
  int get hashCode => Object.hash(runtimeType, form, picked);

  @override
  String toString() {
    return 'AddMedicationState(form: $form, picked: $picked)';
  }
}

/// @nodoc
abstract mixin class $AddMedicationStateCopyWith<$Res> {
  factory $AddMedicationStateCopyWith(
          AddMedicationState value, $Res Function(AddMedicationState) _then) =
      _$AddMedicationStateCopyWithImpl;
  @useResult
  $Res call({MedicationFormState form, SeededMedicationModel? picked});

  $MedicationFormStateCopyWith<$Res> get form;
  $SeededMedicationModelCopyWith<$Res>? get picked;
}

/// @nodoc
class _$AddMedicationStateCopyWithImpl<$Res>
    implements $AddMedicationStateCopyWith<$Res> {
  _$AddMedicationStateCopyWithImpl(this._self, this._then);

  final AddMedicationState _self;
  final $Res Function(AddMedicationState) _then;

  /// Create a copy of AddMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? form = null,
    Object? picked = freezed,
  }) {
    return _then(_self.copyWith(
      form: null == form
          ? _self.form
          : form // ignore: cast_nullable_to_non_nullable
              as MedicationFormState,
      picked: freezed == picked
          ? _self.picked
          : picked // ignore: cast_nullable_to_non_nullable
              as SeededMedicationModel?,
    ));
  }

  /// Create a copy of AddMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicationFormStateCopyWith<$Res> get form {
    return $MedicationFormStateCopyWith<$Res>(_self.form, (value) {
      return _then(_self.copyWith(form: value));
    });
  }

  /// Create a copy of AddMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SeededMedicationModelCopyWith<$Res>? get picked {
    if (_self.picked == null) {
      return null;
    }

    return $SeededMedicationModelCopyWith<$Res>(_self.picked!, (value) {
      return _then(_self.copyWith(picked: value));
    });
  }
}

/// @nodoc

class _AddMedicationState implements AddMedicationState {
  const _AddMedicationState({required this.form, this.picked});

  @override
  final MedicationFormState form;

  /// The preloaded medication picked from search, which suggests dosages.
  @override
  final SeededMedicationModel? picked;

  /// Create a copy of AddMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddMedicationStateCopyWith<_AddMedicationState> get copyWith =>
      __$AddMedicationStateCopyWithImpl<_AddMedicationState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddMedicationState &&
            (identical(other.form, form) || other.form == form) &&
            (identical(other.picked, picked) || other.picked == picked));
  }

  @override
  int get hashCode => Object.hash(runtimeType, form, picked);

  @override
  String toString() {
    return 'AddMedicationState(form: $form, picked: $picked)';
  }
}

/// @nodoc
abstract mixin class _$AddMedicationStateCopyWith<$Res>
    implements $AddMedicationStateCopyWith<$Res> {
  factory _$AddMedicationStateCopyWith(
          _AddMedicationState value, $Res Function(_AddMedicationState) _then) =
      __$AddMedicationStateCopyWithImpl;
  @override
  @useResult
  $Res call({MedicationFormState form, SeededMedicationModel? picked});

  @override
  $MedicationFormStateCopyWith<$Res> get form;
  @override
  $SeededMedicationModelCopyWith<$Res>? get picked;
}

/// @nodoc
class __$AddMedicationStateCopyWithImpl<$Res>
    implements _$AddMedicationStateCopyWith<$Res> {
  __$AddMedicationStateCopyWithImpl(this._self, this._then);

  final _AddMedicationState _self;
  final $Res Function(_AddMedicationState) _then;

  /// Create a copy of AddMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? form = null,
    Object? picked = freezed,
  }) {
    return _then(_AddMedicationState(
      form: null == form
          ? _self.form
          : form // ignore: cast_nullable_to_non_nullable
              as MedicationFormState,
      picked: freezed == picked
          ? _self.picked
          : picked // ignore: cast_nullable_to_non_nullable
              as SeededMedicationModel?,
    ));
  }

  /// Create a copy of AddMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicationFormStateCopyWith<$Res> get form {
    return $MedicationFormStateCopyWith<$Res>(_self.form, (value) {
      return _then(_self.copyWith(form: value));
    });
  }

  /// Create a copy of AddMedicationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SeededMedicationModelCopyWith<$Res>? get picked {
    if (_self.picked == null) {
      return null;
    }

    return $SeededMedicationModelCopyWith<$Res>(_self.picked!, (value) {
      return _then(_self.copyWith(picked: value));
    });
  }
}

/// @nodoc
mixin _$MedicineDetailsState {
  MedicationFormState get form;
  MedicationDetailModel? get detail;
  AppFailure? get error;
  bool get isLoading;
  bool get isEditing;
  MedicationHistoryEntity? get history;
  AppFailure? get historyError;

  /// Create a copy of MedicineDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MedicineDetailsStateCopyWith<MedicineDetailsState> get copyWith =>
      _$MedicineDetailsStateCopyWithImpl<MedicineDetailsState>(
          this as MedicineDetailsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MedicineDetailsState &&
            (identical(other.form, form) || other.form == form) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isEditing, isEditing) ||
                other.isEditing == isEditing) &&
            (identical(other.history, history) || other.history == history) &&
            (identical(other.historyError, historyError) ||
                other.historyError == historyError));
  }

  @override
  int get hashCode => Object.hash(runtimeType, form, detail, error, isLoading,
      isEditing, history, historyError);

  @override
  String toString() {
    return 'MedicineDetailsState(form: $form, detail: $detail, error: $error, isLoading: $isLoading, isEditing: $isEditing, history: $history, historyError: $historyError)';
  }
}

/// @nodoc
abstract mixin class $MedicineDetailsStateCopyWith<$Res> {
  factory $MedicineDetailsStateCopyWith(MedicineDetailsState value,
          $Res Function(MedicineDetailsState) _then) =
      _$MedicineDetailsStateCopyWithImpl;
  @useResult
  $Res call(
      {MedicationFormState form,
      MedicationDetailModel? detail,
      AppFailure? error,
      bool isLoading,
      bool isEditing,
      MedicationHistoryEntity? history,
      AppFailure? historyError});

  $MedicationFormStateCopyWith<$Res> get form;
  $MedicationDetailModelCopyWith<$Res>? get detail;
}

/// @nodoc
class _$MedicineDetailsStateCopyWithImpl<$Res>
    implements $MedicineDetailsStateCopyWith<$Res> {
  _$MedicineDetailsStateCopyWithImpl(this._self, this._then);

  final MedicineDetailsState _self;
  final $Res Function(MedicineDetailsState) _then;

  /// Create a copy of MedicineDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? form = null,
    Object? detail = freezed,
    Object? error = freezed,
    Object? isLoading = null,
    Object? isEditing = null,
    Object? history = freezed,
    Object? historyError = freezed,
  }) {
    return _then(_self.copyWith(
      form: null == form
          ? _self.form
          : form // ignore: cast_nullable_to_non_nullable
              as MedicationFormState,
      detail: freezed == detail
          ? _self.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as MedicationDetailModel?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppFailure?,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isEditing: null == isEditing
          ? _self.isEditing
          : isEditing // ignore: cast_nullable_to_non_nullable
              as bool,
      history: freezed == history
          ? _self.history
          : history // ignore: cast_nullable_to_non_nullable
              as MedicationHistoryEntity?,
      historyError: freezed == historyError
          ? _self.historyError
          : historyError // ignore: cast_nullable_to_non_nullable
              as AppFailure?,
    ));
  }

  /// Create a copy of MedicineDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicationFormStateCopyWith<$Res> get form {
    return $MedicationFormStateCopyWith<$Res>(_self.form, (value) {
      return _then(_self.copyWith(form: value));
    });
  }

  /// Create a copy of MedicineDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicationDetailModelCopyWith<$Res>? get detail {
    if (_self.detail == null) {
      return null;
    }

    return $MedicationDetailModelCopyWith<$Res>(_self.detail!, (value) {
      return _then(_self.copyWith(detail: value));
    });
  }
}

/// @nodoc

class _MedicineDetailsState extends MedicineDetailsState {
  const _MedicineDetailsState(
      {required this.form,
      this.detail,
      this.error,
      this.isLoading = true,
      this.isEditing = false,
      this.history,
      this.historyError})
      : super._();

  @override
  final MedicationFormState form;
  @override
  final MedicationDetailModel? detail;
  @override
  final AppFailure? error;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isEditing;
  @override
  final MedicationHistoryEntity? history;
  @override
  final AppFailure? historyError;

  /// Create a copy of MedicineDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MedicineDetailsStateCopyWith<_MedicineDetailsState> get copyWith =>
      __$MedicineDetailsStateCopyWithImpl<_MedicineDetailsState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MedicineDetailsState &&
            (identical(other.form, form) || other.form == form) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isEditing, isEditing) ||
                other.isEditing == isEditing) &&
            (identical(other.history, history) || other.history == history) &&
            (identical(other.historyError, historyError) ||
                other.historyError == historyError));
  }

  @override
  int get hashCode => Object.hash(runtimeType, form, detail, error, isLoading,
      isEditing, history, historyError);

  @override
  String toString() {
    return 'MedicineDetailsState(form: $form, detail: $detail, error: $error, isLoading: $isLoading, isEditing: $isEditing, history: $history, historyError: $historyError)';
  }
}

/// @nodoc
abstract mixin class _$MedicineDetailsStateCopyWith<$Res>
    implements $MedicineDetailsStateCopyWith<$Res> {
  factory _$MedicineDetailsStateCopyWith(_MedicineDetailsState value,
          $Res Function(_MedicineDetailsState) _then) =
      __$MedicineDetailsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {MedicationFormState form,
      MedicationDetailModel? detail,
      AppFailure? error,
      bool isLoading,
      bool isEditing,
      MedicationHistoryEntity? history,
      AppFailure? historyError});

  @override
  $MedicationFormStateCopyWith<$Res> get form;
  @override
  $MedicationDetailModelCopyWith<$Res>? get detail;
}

/// @nodoc
class __$MedicineDetailsStateCopyWithImpl<$Res>
    implements _$MedicineDetailsStateCopyWith<$Res> {
  __$MedicineDetailsStateCopyWithImpl(this._self, this._then);

  final _MedicineDetailsState _self;
  final $Res Function(_MedicineDetailsState) _then;

  /// Create a copy of MedicineDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? form = null,
    Object? detail = freezed,
    Object? error = freezed,
    Object? isLoading = null,
    Object? isEditing = null,
    Object? history = freezed,
    Object? historyError = freezed,
  }) {
    return _then(_MedicineDetailsState(
      form: null == form
          ? _self.form
          : form // ignore: cast_nullable_to_non_nullable
              as MedicationFormState,
      detail: freezed == detail
          ? _self.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as MedicationDetailModel?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppFailure?,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isEditing: null == isEditing
          ? _self.isEditing
          : isEditing // ignore: cast_nullable_to_non_nullable
              as bool,
      history: freezed == history
          ? _self.history
          : history // ignore: cast_nullable_to_non_nullable
              as MedicationHistoryEntity?,
      historyError: freezed == historyError
          ? _self.historyError
          : historyError // ignore: cast_nullable_to_non_nullable
              as AppFailure?,
    ));
  }

  /// Create a copy of MedicineDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicationFormStateCopyWith<$Res> get form {
    return $MedicationFormStateCopyWith<$Res>(_self.form, (value) {
      return _then(_self.copyWith(form: value));
    });
  }

  /// Create a copy of MedicineDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MedicationDetailModelCopyWith<$Res>? get detail {
    if (_self.detail == null) {
      return null;
    }

    return $MedicationDetailModelCopyWith<$Res>(_self.detail!, (value) {
      return _then(_self.copyWith(detail: value));
    });
  }
}

// dart format on
