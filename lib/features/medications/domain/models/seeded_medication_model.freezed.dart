// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seeded_medication_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeededMedicationModel {
  @JsonKey(readValue: _readId)
  String get id;
  String get name;
  List<String> get possibleDosages;
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Create a copy of SeededMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SeededMedicationModelCopyWith<SeededMedicationModel> get copyWith =>
      _$SeededMedicationModelCopyWithImpl<SeededMedicationModel>(
          this as SeededMedicationModel, _$identity);

  /// Serializes this SeededMedicationModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SeededMedicationModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other.possibleDosages, possibleDosages) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(possibleDosages),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'SeededMedicationModel(id: $id, name: $name, possibleDosages: $possibleDosages, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $SeededMedicationModelCopyWith<$Res> {
  factory $SeededMedicationModelCopyWith(SeededMedicationModel value,
          $Res Function(SeededMedicationModel) _then) =
      _$SeededMedicationModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(readValue: _readId) String id,
      String name,
      List<String> possibleDosages,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$SeededMedicationModelCopyWithImpl<$Res>
    implements $SeededMedicationModelCopyWith<$Res> {
  _$SeededMedicationModelCopyWithImpl(this._self, this._then);

  final SeededMedicationModel _self;
  final $Res Function(SeededMedicationModel) _then;

  /// Create a copy of SeededMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? possibleDosages = null,
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
      possibleDosages: null == possibleDosages
          ? _self.possibleDosages
          : possibleDosages // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
}

/// @nodoc
@JsonSerializable()
class _SeededMedicationModel implements SeededMedicationModel {
  const _SeededMedicationModel(
      {@JsonKey(readValue: _readId) required this.id,
      required this.name,
      required final List<String> possibleDosages,
      required this.createdAt,
      required this.updatedAt})
      : _possibleDosages = possibleDosages;
  factory _SeededMedicationModel.fromJson(Map<String, dynamic> json) =>
      _$SeededMedicationModelFromJson(json);

  @override
  @JsonKey(readValue: _readId)
  final String id;
  @override
  final String name;
  final List<String> _possibleDosages;
  @override
  List<String> get possibleDosages {
    if (_possibleDosages is EqualUnmodifiableListView) return _possibleDosages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_possibleDosages);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  /// Create a copy of SeededMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SeededMedicationModelCopyWith<_SeededMedicationModel> get copyWith =>
      __$SeededMedicationModelCopyWithImpl<_SeededMedicationModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SeededMedicationModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SeededMedicationModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._possibleDosages, _possibleDosages) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_possibleDosages),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'SeededMedicationModel(id: $id, name: $name, possibleDosages: $possibleDosages, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$SeededMedicationModelCopyWith<$Res>
    implements $SeededMedicationModelCopyWith<$Res> {
  factory _$SeededMedicationModelCopyWith(_SeededMedicationModel value,
          $Res Function(_SeededMedicationModel) _then) =
      __$SeededMedicationModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(readValue: _readId) String id,
      String name,
      List<String> possibleDosages,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$SeededMedicationModelCopyWithImpl<$Res>
    implements _$SeededMedicationModelCopyWith<$Res> {
  __$SeededMedicationModelCopyWithImpl(this._self, this._then);

  final _SeededMedicationModel _self;
  final $Res Function(_SeededMedicationModel) _then;

  /// Create a copy of SeededMedicationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? possibleDosages = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_SeededMedicationModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      possibleDosages: null == possibleDosages
          ? _self._possibleDosages
          : possibleDosages // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
}

// dart format on
