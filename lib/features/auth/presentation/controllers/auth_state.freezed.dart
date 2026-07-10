// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthState {
  User? get currentUser;
  bool get isInitialized;
  bool get isAuthLoading;
  bool get isInitialSyncInProgress;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthStateCopyWith<AuthState> get copyWith =>
      _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthState &&
            (identical(other.currentUser, currentUser) ||
                other.currentUser == currentUser) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.isAuthLoading, isAuthLoading) ||
                other.isAuthLoading == isAuthLoading) &&
            (identical(
                    other.isInitialSyncInProgress, isInitialSyncInProgress) ||
                other.isInitialSyncInProgress == isInitialSyncInProgress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentUser, isInitialized,
      isAuthLoading, isInitialSyncInProgress);

  @override
  String toString() {
    return 'AuthState(currentUser: $currentUser, isInitialized: $isInitialized, isAuthLoading: $isAuthLoading, isInitialSyncInProgress: $isInitialSyncInProgress)';
  }
}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) =
      _$AuthStateCopyWithImpl;
  @useResult
  $Res call(
      {User? currentUser,
      bool isInitialized,
      bool isAuthLoading,
      bool isInitialSyncInProgress});
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res> implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentUser = freezed,
    Object? isInitialized = null,
    Object? isAuthLoading = null,
    Object? isInitialSyncInProgress = null,
  }) {
    return _then(_self.copyWith(
      currentUser: freezed == currentUser
          ? _self.currentUser
          : currentUser // ignore: cast_nullable_to_non_nullable
              as User?,
      isInitialized: null == isInitialized
          ? _self.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isAuthLoading: null == isAuthLoading
          ? _self.isAuthLoading
          : isAuthLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialSyncInProgress: null == isInitialSyncInProgress
          ? _self.isInitialSyncInProgress
          : isInitialSyncInProgress // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _AuthState extends AuthState {
  const _AuthState(
      {this.currentUser,
      this.isInitialized = false,
      this.isAuthLoading = false,
      this.isInitialSyncInProgress = false})
      : super._();

  @override
  final User? currentUser;
  @override
  @JsonKey()
  final bool isInitialized;
  @override
  @JsonKey()
  final bool isAuthLoading;
  @override
  @JsonKey()
  final bool isInitialSyncInProgress;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthStateCopyWith<_AuthState> get copyWith =>
      __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthState &&
            (identical(other.currentUser, currentUser) ||
                other.currentUser == currentUser) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.isAuthLoading, isAuthLoading) ||
                other.isAuthLoading == isAuthLoading) &&
            (identical(
                    other.isInitialSyncInProgress, isInitialSyncInProgress) ||
                other.isInitialSyncInProgress == isInitialSyncInProgress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentUser, isInitialized,
      isAuthLoading, isInitialSyncInProgress);

  @override
  String toString() {
    return 'AuthState(currentUser: $currentUser, isInitialized: $isInitialized, isAuthLoading: $isAuthLoading, isInitialSyncInProgress: $isInitialSyncInProgress)';
  }
}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(
          _AuthState value, $Res Function(_AuthState) _then) =
      __$AuthStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {User? currentUser,
      bool isInitialized,
      bool isAuthLoading,
      bool isInitialSyncInProgress});
}

/// @nodoc
class __$AuthStateCopyWithImpl<$Res> implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? currentUser = freezed,
    Object? isInitialized = null,
    Object? isAuthLoading = null,
    Object? isInitialSyncInProgress = null,
  }) {
    return _then(_AuthState(
      currentUser: freezed == currentUser
          ? _self.currentUser
          : currentUser // ignore: cast_nullable_to_non_nullable
              as User?,
      isInitialized: null == isInitialized
          ? _self.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isAuthLoading: null == isAuthLoading
          ? _self.isAuthLoading
          : isAuthLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialSyncInProgress: null == isInitialSyncInProgress
          ? _self.isInitialSyncInProgress
          : isInitialSyncInProgress // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
