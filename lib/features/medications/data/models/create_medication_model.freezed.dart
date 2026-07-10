// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_medication_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateMedicationModel {
  String get name;
  String get dosage;
  String? get notes;
  DosingScheduleModel? get morning;
  DosingScheduleModel? get afternoon;
  DosingScheduleModel? get evening;

  /// Create a copy of CreateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CreateMedicationModelCopyWith<CreateMedicationModel> get copyWith =>
      _$CreateMedicationModelCopyWithImpl<CreateMedicationModel>(
          this as CreateMedicationModel, _$identity);

  /// Serializes this CreateMedicationModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreateMedicationModel &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.morning, morning) || other.morning == morning) &&
            (identical(other.afternoon, afternoon) ||
                other.afternoon == afternoon) &&
            (identical(other.evening, evening) || other.evening == evening));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, dosage, notes, morning, afternoon, evening);

  @override
  String toString() {
    return 'CreateMedicationModel(name: $name, dosage: $dosage, notes: $notes, morning: $morning, afternoon: $afternoon, evening: $evening)';
  }
}

/// @nodoc
abstract mixin class $CreateMedicationModelCopyWith<$Res> {
  factory $CreateMedicationModelCopyWith(CreateMedicationModel value,
          $Res Function(CreateMedicationModel) _then) =
      _$CreateMedicationModelCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      String dosage,
      String? notes,
      DosingScheduleModel? morning,
      DosingScheduleModel? afternoon,
      DosingScheduleModel? evening});

  $DosingScheduleModelCopyWith<$Res>? get morning;
  $DosingScheduleModelCopyWith<$Res>? get afternoon;
  $DosingScheduleModelCopyWith<$Res>? get evening;
}

/// @nodoc
class _$CreateMedicationModelCopyWithImpl<$Res>
    implements $CreateMedicationModelCopyWith<$Res> {
  _$CreateMedicationModelCopyWithImpl(this._self, this._then);

  final CreateMedicationModel _self;
  final $Res Function(CreateMedicationModel) _then;

  /// Create a copy of CreateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dosage = null,
    Object? notes = freezed,
    Object? morning = freezed,
    Object? afternoon = freezed,
    Object? evening = freezed,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dosage: null == dosage
          ? _self.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String,
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

  /// Create a copy of CreateMedicationModel
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

  /// Create a copy of CreateMedicationModel
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

  /// Create a copy of CreateMedicationModel
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
class _CreateMedicationModel implements CreateMedicationModel {
  const _CreateMedicationModel(
      {required this.name,
      required this.dosage,
      this.notes,
      this.morning,
      this.afternoon,
      this.evening});
  factory _CreateMedicationModel.fromJson(Map<String, dynamic> json) =>
      _$CreateMedicationModelFromJson(json);

  @override
  final String name;
  @override
  final String dosage;
  @override
  final String? notes;
  @override
  final DosingScheduleModel? morning;
  @override
  final DosingScheduleModel? afternoon;
  @override
  final DosingScheduleModel? evening;

  /// Create a copy of CreateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CreateMedicationModelCopyWith<_CreateMedicationModel> get copyWith =>
      __$CreateMedicationModelCopyWithImpl<_CreateMedicationModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CreateMedicationModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CreateMedicationModel &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.morning, morning) || other.morning == morning) &&
            (identical(other.afternoon, afternoon) ||
                other.afternoon == afternoon) &&
            (identical(other.evening, evening) || other.evening == evening));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, dosage, notes, morning, afternoon, evening);

  @override
  String toString() {
    return 'CreateMedicationModel(name: $name, dosage: $dosage, notes: $notes, morning: $morning, afternoon: $afternoon, evening: $evening)';
  }
}

/// @nodoc
abstract mixin class _$CreateMedicationModelCopyWith<$Res>
    implements $CreateMedicationModelCopyWith<$Res> {
  factory _$CreateMedicationModelCopyWith(_CreateMedicationModel value,
          $Res Function(_CreateMedicationModel) _then) =
      __$CreateMedicationModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      String dosage,
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
class __$CreateMedicationModelCopyWithImpl<$Res>
    implements _$CreateMedicationModelCopyWith<$Res> {
  __$CreateMedicationModelCopyWithImpl(this._self, this._then);

  final _CreateMedicationModel _self;
  final $Res Function(_CreateMedicationModel) _then;

  /// Create a copy of CreateMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? dosage = null,
    Object? notes = freezed,
    Object? morning = freezed,
    Object? afternoon = freezed,
    Object? evening = freezed,
  }) {
    return _then(_CreateMedicationModel(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dosage: null == dosage
          ? _self.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String,
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

  /// Create a copy of CreateMedicationModel
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

  /// Create a copy of CreateMedicationModel
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

  /// Create a copy of CreateMedicationModel
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
