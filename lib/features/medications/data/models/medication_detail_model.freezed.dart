// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicationDetailModel {
  @JsonKey(readValue: _readId)
  String get id;
  String get name;
  String get dosage;
  String? get notes;
  DosingScheduleModel? get morning;
  DosingScheduleModel? get afternoon;
  DosingScheduleModel? get evening;
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Create a copy of MedicationDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MedicationDetailModelCopyWith<MedicationDetailModel> get copyWith =>
      _$MedicationDetailModelCopyWithImpl<MedicationDetailModel>(
          this as MedicationDetailModel, _$identity);

  /// Serializes this MedicationDetailModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MedicationDetailModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.morning, morning) || other.morning == morning) &&
            (identical(other.afternoon, afternoon) ||
                other.afternoon == afternoon) &&
            (identical(other.evening, evening) || other.evening == evening) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, dosage, notes, morning,
      afternoon, evening, createdAt, updatedAt);

  @override
  String toString() {
    return 'MedicationDetailModel(id: $id, name: $name, dosage: $dosage, notes: $notes, morning: $morning, afternoon: $afternoon, evening: $evening, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $MedicationDetailModelCopyWith<$Res> {
  factory $MedicationDetailModelCopyWith(MedicationDetailModel value,
          $Res Function(MedicationDetailModel) _then) =
      _$MedicationDetailModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(readValue: _readId) String id,
      String name,
      String dosage,
      String? notes,
      DosingScheduleModel? morning,
      DosingScheduleModel? afternoon,
      DosingScheduleModel? evening,
      DateTime createdAt,
      DateTime updatedAt});

  $DosingScheduleModelCopyWith<$Res>? get morning;
  $DosingScheduleModelCopyWith<$Res>? get afternoon;
  $DosingScheduleModelCopyWith<$Res>? get evening;
}

/// @nodoc
class _$MedicationDetailModelCopyWithImpl<$Res>
    implements $MedicationDetailModelCopyWith<$Res> {
  _$MedicationDetailModelCopyWithImpl(this._self, this._then);

  final MedicationDetailModel _self;
  final $Res Function(MedicationDetailModel) _then;

  /// Create a copy of MedicationDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dosage = null,
    Object? notes = freezed,
    Object? morning = freezed,
    Object? afternoon = freezed,
    Object? evening = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }

  /// Create a copy of MedicationDetailModel
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

  /// Create a copy of MedicationDetailModel
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

  /// Create a copy of MedicationDetailModel
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
class _MedicationDetailModel implements MedicationDetailModel {
  const _MedicationDetailModel(
      {@JsonKey(readValue: _readId) required this.id,
      required this.name,
      required this.dosage,
      this.notes,
      this.morning,
      this.afternoon,
      this.evening,
      required this.createdAt,
      required this.updatedAt});
  factory _MedicationDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationDetailModelFromJson(json);

  @override
  @JsonKey(readValue: _readId)
  final String id;
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
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  /// Create a copy of MedicationDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MedicationDetailModelCopyWith<_MedicationDetailModel> get copyWith =>
      __$MedicationDetailModelCopyWithImpl<_MedicationDetailModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MedicationDetailModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MedicationDetailModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.morning, morning) || other.morning == morning) &&
            (identical(other.afternoon, afternoon) ||
                other.afternoon == afternoon) &&
            (identical(other.evening, evening) || other.evening == evening) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, dosage, notes, morning,
      afternoon, evening, createdAt, updatedAt);

  @override
  String toString() {
    return 'MedicationDetailModel(id: $id, name: $name, dosage: $dosage, notes: $notes, morning: $morning, afternoon: $afternoon, evening: $evening, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$MedicationDetailModelCopyWith<$Res>
    implements $MedicationDetailModelCopyWith<$Res> {
  factory _$MedicationDetailModelCopyWith(_MedicationDetailModel value,
          $Res Function(_MedicationDetailModel) _then) =
      __$MedicationDetailModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(readValue: _readId) String id,
      String name,
      String dosage,
      String? notes,
      DosingScheduleModel? morning,
      DosingScheduleModel? afternoon,
      DosingScheduleModel? evening,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $DosingScheduleModelCopyWith<$Res>? get morning;
  @override
  $DosingScheduleModelCopyWith<$Res>? get afternoon;
  @override
  $DosingScheduleModelCopyWith<$Res>? get evening;
}

/// @nodoc
class __$MedicationDetailModelCopyWithImpl<$Res>
    implements _$MedicationDetailModelCopyWith<$Res> {
  __$MedicationDetailModelCopyWithImpl(this._self, this._then);

  final _MedicationDetailModel _self;
  final $Res Function(_MedicationDetailModel) _then;

  /// Create a copy of MedicationDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dosage = null,
    Object? notes = freezed,
    Object? morning = freezed,
    Object? afternoon = freezed,
    Object? evening = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_MedicationDetailModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }

  /// Create a copy of MedicationDetailModel
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

  /// Create a copy of MedicationDetailModel
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

  /// Create a copy of MedicationDetailModel
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
