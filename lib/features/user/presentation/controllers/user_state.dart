import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_state.freezed.dart';

@freezed
abstract class UserState with _$UserState {
  const factory UserState({
    UserEntity? userEntity,
    @Default(false) bool isInitialized,
    @Default(false) bool isLoading,
  }) = _UserState;

  const UserState._();

  bool get hasProfile => userEntity != null;
}
