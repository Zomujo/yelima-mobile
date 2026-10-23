import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_state.freezed.dart';

@freezed
abstract class UserState with _$UserState {
  const factory UserState({
    UserEntity? userEntity,
    @Default(false) bool isInitialized,
    @Default(false) bool isLoading,

    /// The profile couldn't be loaded (offline, no cache); not the same as a new user with no profile.
    @Default(false) bool profileUnavailable,
  }) = _UserState;

  const UserState._();

  bool get hasProfile => userEntity != null;
}
