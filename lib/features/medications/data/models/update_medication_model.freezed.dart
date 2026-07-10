// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_medication_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateMedicationModel {
  String? get dosage;
  String? get notes;
  DosingScheduleModel? get morning;
  DosingScheduleModel? get afternoon;
  DosingScheduleModel? get evening;

  /// Create a copy of UpdateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UpdateMedicationModelCopyWith<UpdateMedicationModel> get copyWith =>
      _$UpdateMedicationModelCopyWithImpl<UpdateMedicationModel>(
          this as UpdateMedicationModel, _$identity);

  /// Serializes this UpdateMedicationModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UpdateMedicationModel &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.morning, morning) || other.morning == morning) &&
            (identical(other.afternoon, afternoon) ||
                other.afternoon == afternoon) &&
            (identical(other.evening, evening) || other.evening == evening));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, dosage, notes, morning, afternoon, evening);

  @override
  String toString() {
    return 'UpdateMedicationModel(dosage: $dosage, notes: $notes, morning: $morning, afternoon: $afternoon, evening: $evening)';
  }
}

/// @nodoc
abstract mixin class $UpdateMedicationModelCopyWith<$Res> {
  factory $UpdateMedicationModelCopyWith(UpdateMedicationModel value,
          $Res Function(UpdateMedicationModel) _then) =
      _$UpdateMedicationModelCopyWithImpl;
  @useResult
  $Res call(
      {String? dosage,
      String? notes,
      DosingScheduleModel? morning,
      DosingScheduleModel? afternoon,
      DosingScheduleModel? evening});

  $DosingScheduleModelCopyWith<$Res>? get morning;
  $DosingScheduleModelCopyWith<$Res>? get afternoon;
  $DosingScheduleModelCopyWith<$Res>? get evening;
}

/// @nodoc
class _$UpdateMedicationModelCopyWithImpl<$Res>
    implements $UpdateMedicationModelCopyWith<$Res> {
  _$UpdateMedicationModelCopyWithImpl(this._self, this._then);

  final UpdateMedicationModel _self;
  final $Res Function(UpdateMedicationModel) _then;

  /// Create a copy of UpdateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dosage = freezed,
    Object? notes = freezed,
    Object? morning = freezed,
    Object? afternoon = freezed,
    Object? evening = freezed,
  }) {
    return _then(_self.copyWith(
      dosage: freezed == dosage
          ? _self.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      morning: freezed == morning
          ? _self.morning
          : morning // ignore: cast_nullable_to_non_nullable
              as DosingScheduleModel?,
      afternoon: freezed == afternoon
          ? _self.afternoon
          : afternoon // ignore: cast_nullable_to_non_nullable
              as DosingScheduleModel?,
      evening: freezed == evening
          ? _self.evening
          : evening // ignore: cast_nullable_to_non_nullable
              as DosingScheduleModel?,
    ));
  }

  /// Create a copy of UpdateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DosingScheduleModelCopyWith<$Res>? get morning {
    if (_self.morning == null) {
      return null;
    }

    return $DosingScheduleModelCopyWith<$Res>(_self.morning!, (value) {
      return _then(_self.copyWith(morning: value));
    });
  }

  /// Create a copy of UpdateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DosingScheduleModelCopyWith<$Res>? get afternoon {
    if (_self.afternoon == null) {
      return null;
    }

    return $DosingScheduleModelCopyWith<$Res>(_self.afternoon!, (value) {
      return _then(_self.copyWith(afternoon: value));
    });
  }

  /// Create a copy of UpdateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DosingScheduleModelCopyWith<$Res>? get evening {
    if (_self.evening == null) {
      return null;
    }

    return $DosingScheduleModelCopyWith<$Res>(_self.evening!, (value) {
      return _then(_self.copyWith(evening: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _UpdateMedicationModel implements UpdateMedicationModel {
  const _UpdateMedicationModel(
      {this.dosage, this.notes, this.morning, this.afternoon, this.evening});
  factory _UpdateMedicationModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateMedicationModelFromJson(json);

  @override
  final String? dosage;
  @override
  final String? notes;
  @override
  final DosingScheduleModel? morning;
  @override
  final DosingScheduleModel? afternoon;
  @override
  final DosingScheduleModel? evening;

  /// Create a copy of UpdateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateMedicationModelCopyWith<_UpdateMedicationModel> get copyWith =>
      __$UpdateMedicationModelCopyWithImpl<_UpdateMedicationModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UpdateMedicationModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateMedicationModel &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.morning, morning) || other.morning == morning) &&
            (identical(other.afternoon, afternoon) ||
                other.afternoon == afternoon) &&
            (identical(other.evening, evening) || other.evening == evening));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, dosage, notes, morning, afternoon, evening);

  @override
  String toString() {
    return 'UpdateMedicationModel(dosage: $dosage, notes: $notes, morning: $morning, afternoon: $afternoon, evening: $evening)';
  }
}

/// @nodoc
abstract mixin class _$UpdateMedicationModelCopyWith<$Res>
    implements $UpdateMedicationModelCopyWith<$Res> {
  factory _$UpdateMedicationModelCopyWith(_UpdateMedicationModel value,
          $Res Function(_UpdateMedicationModel) _then) =
      __$UpdateMedicationModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? dosage,
      String? notes,
      DosingScheduleModel? morning,
      DosingScheduleModel? afternoon,
      DosingScheduleModel? evening});

  @override
  $DosingScheduleModelCopyWith<$Res>? get morning;
  @override
  $DosingScheduleModelCopyWith<$Res>? get afternoon;
  @override
  $DosingScheduleModelCopyWith<$Res>? get evening;
}

/// @nodoc
class __$UpdateMedicationModelCopyWithImpl<$Res>
    implements _$UpdateMedicationModelCopyWith<$Res> {
  __$UpdateMedicationModelCopyWithImpl(this._self, this._then);

  final _UpdateMedicationModel _self;
  final $Res Function(_UpdateMedicationModel) _then;

  /// Create a copy of UpdateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? dosage = freezed,
    Object? notes = freezed,
    Object? morning = freezed,
    Object? afternoon = freezed,
    Object? evening = freezed,
  }) {
    return _then(_UpdateMedicationModel(
      dosage: freezed == dosage
          ? _self.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      morning: freezed == morning
          ? _self.morning
          : morning // ignore: cast_nullable_to_non_nullable
              as DosingScheduleModel?,
      afternoon: freezed == afternoon
          ? _self.afternoon
          : afternoon // ignore: cast_nullable_to_non_nullable
              as DosingScheduleModel?,
      evening: freezed == evening
          ? _self.evening
          : evening // ignore: cast_nullable_to_non_nullable
              as DosingScheduleModel?,
    ));
  }

  /// Create a copy of UpdateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DosingScheduleModelCopyWith<$Res>? get morning {
    if (_self.morning == null) {
      return null;
    }

    return $DosingScheduleModelCopyWith<$Res>(_self.morning!, (value) {
      return _then(_self.copyWith(morning: value));
    });
  }

  /// Create a copy of UpdateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DosingScheduleModelCopyWith<$Res>? get afternoon {
    if (_self.afternoon == null) {
      return null;
    }

    return $DosingScheduleModelCopyWith<$Res>(_self.afternoon!, (value) {
      return _then(_self.copyWith(afternoon: value));
    });
  }

  /// Create a copy of UpdateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DosingScheduleModelCopyWith<$Res>? get evening {
    if (_self.evening == null) {
      return null;
    }

    return $DosingScheduleModelCopyWith<$Res>(_self.evening!, (value) {
      return _then(_self.copyWith(evening: value));
    });
  }
}

// dart format on
