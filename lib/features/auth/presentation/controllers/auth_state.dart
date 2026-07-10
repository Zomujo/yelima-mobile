import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';



part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    User? currentUser,
    @Default(false) bool isInitialized,
    @Default(false) bool isAuthLoading,
    @Default(false) bool isInitialSyncInProgress,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => currentUser != null;
}
