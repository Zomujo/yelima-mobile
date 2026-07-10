// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserEntity {
  String get id;
  String get email;
  String? get firstName;
  String? get lastName;
  String? get gender;
  DateTime? get dateOfBirth;
  List<String> get conditions;
  bool get hasConsented;
  RegistrationStatus get registrationStatus;
  String? get modeOfRegistration; // 'google', 'apple', 'email'
  DateTime? get createdAt;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserEntityCopyWith<UserEntity> get copyWith =>
      _$UserEntityCopyWithImpl<UserEntity>(this as UserEntity, _$identity);

  /// Serializes this UserEntity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserEntity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            const DeepCollectionEquality()
                .equals(other.conditions, conditions) &&
            (identical(other.hasConsented, hasConsented) ||
                other.hasConsented == hasConsented) &&
            (identical(other.registrationStatus, registrationStatus) ||
                other.registrationStatus == registrationStatus) &&
            (identical(other.modeOfRegistration, modeOfRegistration) ||
                other.modeOfRegistration == modeOfRegistration) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      firstName,
      lastName,
      gender,
      dateOfBirth,
      const DeepCollectionEquality().hash(conditions),
      hasConsented,
      registrationStatus,
      modeOfRegistration,
      createdAt);

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, firstName: $firstName, lastName: $lastName, gender: $gender, dateOfBirth: $dateOfBirth, conditions: $conditions, hasConsented: $hasConsented, registrationStatus: $registrationStatus, modeOfRegistration: $modeOfRegistration, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $UserEntityCopyWith<$Res> {
  factory $UserEntityCopyWith(
          UserEntity value, $Res Function(UserEntity) _then) =
      _$UserEntityCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String email,
      String? firstName,
      String? lastName,
      String? gender,
      DateTime? dateOfBirth,
      List<String> conditions,
      bool hasConsented,
      RegistrationStatus registrationStatus,
      String? modeOfRegistration,
      DateTime? createdAt});
}

/// @nodoc
class _$UserEntityCopyWithImpl<$Res> implements $UserEntityCopyWith<$Res> {
  _$UserEntityCopyWithImpl(this._self, this._then);

  final UserEntity _self;
  final $Res Function(UserEntity) _then;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? conditions = null,
    Object? hasConsented = null,
    Object? registrationStatus = null,
    Object? modeOfRegistration = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _self.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      conditions: null == conditions
          ? _self.conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasConsented: null == hasConsented
          ? _self.hasConsented
          : hasConsented // ignore: cast_nullable_to_non_nullable
              as bool,
      registrationStatus: null == registrationStatus
          ? _self.registrationStatus
          : registrationStatus // ignore: cast_nullable_to_non_nullable
              as RegistrationStatus,
      modeOfRegistration: freezed == modeOfRegistration
          ? _self.modeOfRegistration
          : modeOfRegistration // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _UserEntity extends UserEntity {
  const _UserEntity(
      {required this.id,
      required this.email,
      this.firstName,
      this.lastName,
      this.gender,
      this.dateOfBirth,
      final List<String> conditions = const [],
      this.hasConsented = false,
      this.registrationStatus = RegistrationStatus.personalDetails,
      this.modeOfRegistration,
      this.createdAt})
      : _conditions = conditions,
        super._();
  factory _UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? gender;
  @override
  final DateTime? dateOfBirth;
  final List<String> _conditions;
  @override
  @JsonKey()
  List<String> get conditions {
    if (_conditions is EqualUnmodifiableListView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conditions);
  }

  @override
  @JsonKey()
  final bool hasConsented;
  @override
  @JsonKey()
  final RegistrationStatus registrationStatus;
  @override
  final String? modeOfRegistration;
// 'google', 'apple', 'email'
  @override
  final DateTime? createdAt;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserEntityCopyWith<_UserEntity> get copyWith =>
      __$UserEntityCopyWithImpl<_UserEntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserEntityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserEntity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            const DeepCollectionEquality()
                .equals(other._conditions, _conditions) &&
            (identical(other.hasConsented, hasConsented) ||
                other.hasConsented == hasConsented) &&
            (identical(other.registrationStatus, registrationStatus) ||
                other.registrationStatus == registrationStatus) &&
            (identical(other.modeOfRegistration, modeOfRegistration) ||
                other.modeOfRegistration == modeOfRegistration) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      firstName,
      lastName,
      gender,
      dateOfBirth,
      const DeepCollectionEquality().hash(_conditions),
      hasConsented,
      registrationStatus,
      modeOfRegistration,
      createdAt);

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, firstName: $firstName, lastName: $lastName, gender: $gender, dateOfBirth: $dateOfBirth, conditions: $conditions, hasConsented: $hasConsented, registrationStatus: $registrationStatus, modeOfRegistration: $modeOfRegistration, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$UserEntityCopyWith<$Res>
    implements $UserEntityCopyWith<$Res> {
  factory _$UserEntityCopyWith(
          _UserEntity value, $Res Function(_UserEntity) _then) =
      __$UserEntityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String? firstName,
      String? lastName,
      String? gender,
      DateTime? dateOfBirth,
      List<String> conditions,
      bool hasConsented,
      RegistrationStatus registrationStatus,
      String? modeOfRegistration,
      DateTime? createdAt});
}

/// @nodoc
class __$UserEntityCopyWithImpl<$Res> implements _$UserEntityCopyWith<$Res> {
  __$UserEntityCopyWithImpl(this._self, this._then);

  final _UserEntity _self;
  final $Res Function(_UserEntity) _then;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? conditions = null,
    Object? hasConsented = null,
    Object? registrationStatus = null,
    Object? modeOfRegistration = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_UserEntity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _self.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      conditions: null == conditions
          ? _self._conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasConsented: null == hasConsented
          ? _self.hasConsented
          : hasConsented // ignore: cast_nullable_to_non_nullable
              as bool,
      registrationStatus: null == registrationStatus
          ? _self.registrationStatus
          : registrationStatus // ignore: cast_nullable_to_non_nullable
              as RegistrationStatus,
      modeOfRegistration: freezed == modeOfRegistration
          ? _self.modeOfRegistration
          : modeOfRegistration // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
