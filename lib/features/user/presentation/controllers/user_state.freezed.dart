// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserState {
  UserEntity? get userEntity;
  bool get isInitialized;
  bool get isLoading;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserStateCopyWith<UserState> get copyWith =>
      _$UserStateCopyWithImpl<UserState>(this as UserState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserState &&
            (identical(other.userEntity, userEntity) ||
                other.userEntity == userEntity) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, userEntity, isInitialized, isLoading);

  @override
  String toString() {
    return 'UserState(userEntity: $userEntity, isInitialized: $isInitialized, isLoading: $isLoading)';
  }
}

/// @nodoc
abstract mixin class $UserStateCopyWith<$Res> {
  factory $UserStateCopyWith(UserState value, $Res Function(UserState) _then) =
      _$UserStateCopyWithImpl;
  @useResult
  $Res call({UserEntity? userEntity, bool isInitialized, bool isLoading});

  $UserEntityCopyWith<$Res>? get userEntity;
}

/// @nodoc
class _$UserStateCopyWithImpl<$Res> implements $UserStateCopyWith<$Res> {
  _$UserStateCopyWithImpl(this._self, this._then);

  final UserState _self;
  final $Res Function(UserState) _then;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userEntity = freezed,
    Object? isInitialized = null,
    Object? isLoading = null,
  }) {
    return _then(_self.copyWith(
      userEntity: freezed == userEntity
          ? _self.userEntity
          : userEntity // ignore: cast_nullable_to_non_nullable
              as UserEntity?,
      isInitialized: null == isInitialized
          ? _self.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserEntityCopyWith<$Res>? get userEntity {
    if (_self.userEntity == null) {
      return null;
    }

    return $UserEntityCopyWith<$Res>(_self.userEntity!, (value) {
      return _then(_self.copyWith(userEntity: value));
    });
  }
}

/// @nodoc

class _UserState extends UserState {
  const _UserState(
      {this.userEntity, this.isInitialized = false, this.isLoading = false})
      : super._();

  @override
  final UserEntity? userEntity;
  @override
  @JsonKey()
  final bool isInitialized;
  @override
  @JsonKey()
  final bool isLoading;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserStateCopyWith<_UserState> get copyWith =>
      __$UserStateCopyWithImpl<_UserState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserState &&
            (identical(other.userEntity, userEntity) ||
                other.userEntity == userEntity) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, userEntity, isInitialized, isLoading);

  @override
  String toString() {
    return 'UserState(userEntity: $userEntity, isInitialized: $isInitialized, isLoading: $isLoading)';
  }
}

/// @nodoc
abstract mixin class _$UserStateCopyWith<$Res>
    implements $UserStateCopyWith<$Res> {
  factory _$UserStateCopyWith(
          _UserState value, $Res Function(_UserState) _then) =
      __$UserStateCopyWithImpl;
  @override
  @useResult
  $Res call({UserEntity? userEntity, bool isInitialized, bool isLoading});

  @override
  $UserEntityCopyWith<$Res>? get userEntity;
}

/// @nodoc
class __$UserStateCopyWithImpl<$Res> implements _$UserStateCopyWith<$Res> {
  __$UserStateCopyWithImpl(this._self, this._then);

  final _UserState _self;
  final $Res Function(_UserState) _then;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userEntity = freezed,
    Object? isInitialized = null,
    Object? isLoading = null,
  }) {
    return _then(_UserState(
      userEntity: freezed == userEntity
          ? _self.userEntity
          : userEntity // ignore: cast_nullable_to_non_nullable
              as UserEntity?,
      isInitialized: null == isInitialized
          ? _self.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserEntityCopyWith<$Res>? get userEntity {
    if (_self.userEntity == null) {
      return null;
    }

    return $UserEntityCopyWith<$Res>(_self.userEntity!, (value) {
      return _then(_self.copyWith(userEntity: value));
    });
  }
}

// dart format on
