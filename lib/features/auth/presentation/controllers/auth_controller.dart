import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:yelima/core/managers/token_manager.dart';

import '../../../../shared/widgets/loaders/global_async_loader.dart';
import '../../../../shared/utils/app_snackbar.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import 'auth_state.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  final SessionLifecycleService _sessionLifecycleService;
  StreamSubscription<User?>? _authStateSubscription;

  AuthController({
    required AuthRepository repository,
    required SessionLifecycleService sessionLifecycleService,
  })  : _repository = repository,
        _sessionLifecycleService = sessionLifecycleService {
    _initializeAuthStateListener();
  }

  AuthState _state = const AuthState();
  AuthState get state => _state;

  User? get currentUser => _state.currentUser;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isInitialized => _state.isInitialized;
  bool get isAuthLoading => _state.isAuthLoading;
  bool get isInitialSyncInProgress => _state.isInitialSyncInProgress;

  void _updateState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _initializeAuthStateListener() {
    _authStateSubscription?.cancel();
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        _updateState(_state.copyWith(
          currentUser: null,
          isInitialized: true,
        ));
        _sessionLifecycleService.endSession();
      } else {
        _updateState(_state.copyWith(
          currentUser: user,
          isInitialSyncInProgress: true,
          isInitialized: false,
        ));

        try {
          await _refreshAuthAndProfile(user);
        } finally {
          GlobalAsyncLoader.hide();
          _updateState(_state.copyWith(
            isInitialSyncInProgress: false,
            isInitialized: true,
          ));
        }
      }
    });
  }

  Future<void> _refreshAuthAndProfile(User user) async {
    try {
      await user.reload();
      if (FirebaseAuth.instance.currentUser == null) {
        _showSessionExpiredSnackbar();
        await _repository.signOut();
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'user-disabled' || e.code == 'user-token-expired') {
        _showSessionExpiredSnackbar();
        await _repository.signOut();
        return;
      }
    } catch (_) {}

    try {
      await _sessionLifecycleService.startSession(user.uid);
    } catch (e) {
      debugPrint('Error starting session: $e');
    }
  }

  void _showSessionExpiredSnackbar() {
    AppSnackBar.showError(null, message: 'Your session has expired or your account was disabled.');
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> signIn(
      BuildContext context, String email, String password) async {
    if (_state.isAuthLoading) return;
    _updateState(_state.copyWith(isAuthLoading: true));
    GlobalAsyncLoader.show(context, message: "Signing in...");

    final result = await _repository.signIn(email, password);
    _updateState(_state.copyWith(isAuthLoading: false));

    result.fold(
      (error) {
        GlobalAsyncLoader.hide();
        _showError(context, error);
      },
      (_) {
        GlobalAsyncLoader.hide();
      },
    );
  }

  Future<void> register(
      BuildContext context, String email, String password) async {
    if (_state.isAuthLoading) return;
    _updateState(_state.copyWith(isAuthLoading: true));
    GlobalAsyncLoader.show(context, message: "Creating account...");

    final result = await _repository.register(email, password);
    _updateState(_state.copyWith(isAuthLoading: false));

    result.fold(
      (error) {
        GlobalAsyncLoader.hide();
        _showError(context, error);
      },
      (_) {
        GlobalAsyncLoader.hide();
      },
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (_state.isAuthLoading) return;
    _updateState(_state.copyWith(isAuthLoading: true));
    GlobalAsyncLoader.show(context, message: "Continuing with Google...");

    final result = await _repository.signInWithGoogle();
    _updateState(_state.copyWith(isAuthLoading: false));

    result.fold(
      (error) {
        GlobalAsyncLoader.hide();
        _showError(context, error);
      },
      (_) {
        GlobalAsyncLoader.hide();
      },
    );
  }

  Future<void> signInWithApple(BuildContext context) async {
    if (_state.isAuthLoading) return;
    _updateState(_state.copyWith(isAuthLoading: true));
    GlobalAsyncLoader.show(context, message: "Continuing with Apple...");

    final result = await _repository.signInWithApple();
    _updateState(_state.copyWith(isAuthLoading: false));

    result.fold(
      (error) {
        GlobalAsyncLoader.hide();
        _showError(context, error);
      },
      (_) {
        GlobalAsyncLoader.hide();
      },
    );
  }

  Future<bool> sendPasswordResetEmail(
      BuildContext context, String email) async {
    GlobalAsyncLoader.show(context, message: "Sending reset link...");
    final result = await _repository.sendPasswordResetEmail(email);
    GlobalAsyncLoader.hide();

    return result.fold(
      (error) {
        _showError(context, error);
        return false;
      },
      (_) {
        AppSnackBar.showSuccess(context,
            message: 'Password reset link sent! Check your inbox.');
        return true;
      },
    );
  }

  Future<void> deleteAccount(BuildContext context, {String? password}) async {
    GlobalAsyncLoader.show(context, message: "Deleting account...");
    final result = await _repository.deleteAccount(password: password);

    await result.fold(
      (error) async {
        GlobalAsyncLoader.hide();
        _showError(context, error);
      },
      (_) async {
        await _sessionLifecycleService.endSession();
        await TokenManager().clearTokens();
        GlobalAsyncLoader.hide();
        if (context.mounted) {
          AppSnackBar.showSuccess(context,
              message: 'Account successfully deleted.');
        }
      },
    );
  }

  Future<void> signOut(BuildContext context) async {
    GlobalAsyncLoader.show(context, message: "Signing out...");
    await _sessionLifecycleService.endSession();

    final result = await _repository.signOut();
    await TokenManager().clearTokens();

    GlobalAsyncLoader.hide();

    result.fold(
      (error) => _showError(context, error),
      (_) {
        AppSnackBar.showSuccess(context, message: 'Successfully signed out.');
      },
    );
  }

  void _showError(BuildContext context, String message) {
    if (message == 'User cancelled the operation.' || 
        message == 'Sign in cancelled' ||
        message == 'Apple sign-in cancelled' ||
        message == 'Re-authentication was cancelled.') {
      return; // Silent failure for user cancellations
    }
    AppSnackBar.showError(context, message: message);
  }
}
