import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_user.dart';

part 'auth_state.freezed.dart';

/// Who is signed in and where the login flow is.
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    AuthUser? currentUser,
    @Default(false) bool isInitialized,
    @Default(false) bool isAuthLoading,
    @Default(false) bool isInitialSyncInProgress,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => currentUser != null;
}
