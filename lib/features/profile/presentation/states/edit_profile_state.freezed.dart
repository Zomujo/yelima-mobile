// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EditProfileState {
  String get firstName;
  String get lastName;
  String? get gender;
  bool get isSaving;
  bool get hasChanged;
  bool get isButtonEnabled;

  /// Create a copy of EditProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EditProfileStateCopyWith<EditProfileState> get copyWith =>
      _$EditProfileStateCopyWithImpl<EditProfileState>(
          this as EditProfileState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EditProfileState &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.hasChanged, hasChanged) ||
                other.hasChanged == hasChanged) &&
            (identical(other.isButtonEnabled, isButtonEnabled) ||
                other.isButtonEnabled == isButtonEnabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, firstName, lastName, gender,
      isSaving, hasChanged, isButtonEnabled);

  @override
  String toString() {
    return 'EditProfileState(firstName: $firstName, lastName: $lastName, gender: $gender, isSaving: $isSaving, hasChanged: $hasChanged, isButtonEnabled: $isButtonEnabled)';
  }
}

/// @nodoc
abstract mixin class $EditProfileStateCopyWith<$Res> {
  factory $EditProfileStateCopyWith(
          EditProfileState value, $Res Function(EditProfileState) _then) =
      _$EditProfileStateCopyWithImpl;
  @useResult
  $Res call(
      {String firstName,
      String lastName,
      String? gender,
      bool isSaving,
      bool hasChanged,
      bool isButtonEnabled});
}

/// @nodoc
class _$EditProfileStateCopyWithImpl<$Res>
    implements $EditProfileStateCopyWith<$Res> {
  _$EditProfileStateCopyWithImpl(this._self, this._then);

  final EditProfileState _self;
  final $Res Function(EditProfileState) _then;

  /// Create a copy of EditProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? gender = freezed,
    Object? isSaving = null,
    Object? hasChanged = null,
    Object? isButtonEnabled = null,
  }) {
    return _then(_self.copyWith(
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      isSaving: null == isSaving
          ? _self.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      hasChanged: null == hasChanged
          ? _self.hasChanged
          : hasChanged // ignore: cast_nullable_to_non_nullable
              as bool,
      isButtonEnabled: null == isButtonEnabled
          ? _self.isButtonEnabled
          : isButtonEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _EditProfileState implements EditProfileState {
  const _EditProfileState(
      {this.firstName = '',
      this.lastName = '',
      this.gender,
      this.isSaving = false,
      this.hasChanged = false,
      this.isButtonEnabled = false});

  @override
  @JsonKey()
  final String firstName;
  @override
  @JsonKey()
  final String lastName;
  @override
  final String? gender;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  @JsonKey()
  final bool hasChanged;
  @override
  @JsonKey()
  final bool isButtonEnabled;

  /// Create a copy of EditProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EditProfileStateCopyWith<_EditProfileState> get copyWith =>
      __$EditProfileStateCopyWithImpl<_EditProfileState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EditProfileState &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.hasChanged, hasChanged) ||
                other.hasChanged == hasChanged) &&
            (identical(other.isButtonEnabled, isButtonEnabled) ||
                other.isButtonEnabled == isButtonEnabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, firstName, lastName, gender,
      isSaving, hasChanged, isButtonEnabled);

  @override
  String toString() {
    return 'EditProfileState(firstName: $firstName, lastName: $lastName, gender: $gender, isSaving: $isSaving, hasChanged: $hasChanged, isButtonEnabled: $isButtonEnabled)';
  }
}

/// @nodoc
abstract mixin class _$EditProfileStateCopyWith<$Res>
    implements $EditProfileStateCopyWith<$Res> {
  factory _$EditProfileStateCopyWith(
          _EditProfileState value, $Res Function(_EditProfileState) _then) =
      __$EditProfileStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String firstName,
      String lastName,
      String? gender,
      bool isSaving,
      bool hasChanged,
      bool isButtonEnabled});
}

/// @nodoc
class __$EditProfileStateCopyWithImpl<$Res>
    implements _$EditProfileStateCopyWith<$Res> {
  __$EditProfileStateCopyWithImpl(this._self, this._then);

  final _EditProfileState _self;
  final $Res Function(_EditProfileState) _then;

  /// Create a copy of EditProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? gender = freezed,
    Object? isSaving = null,
    Object? hasChanged = null,
    Object? isButtonEnabled = null,
  }) {
    return _then(_EditProfileState(
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      isSaving: null == isSaving
          ? _self.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      hasChanged: null == hasChanged
          ? _self.hasChanged
          : hasChanged // ignore: cast_nullable_to_non_nullable
              as bool,
      isButtonEnabled: null == isButtonEnabled
          ? _self.isButtonEnabled
          : isButtonEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
