import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yelima/core/managers/token_manager.dart';

import '../../../../shared/widgets/loaders/global_async_loader.dart';
import '../../../../shared/utils/app_snackbar.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/services/session_expiry.dart';
import 'auth_state.dart';
import '../../../../core/utils/safe_notifier.dart';

class AuthController extends ChangeNotifier with SafeNotifier {
  // --------------------------------------------------------------------------
  // |                                  State & Dependencies                  |
  // --------------------------------------------------------------------------

  final AuthRepository _repository;
  final SessionLifecycleService _sessionLifecycleService;
  final FirebaseAuth _firebaseAuth;
  final ConnectivityService _connectivity;
  final MutationSyncManager _syncManager;
  final AppDatabase _db;
  final SessionExpiry _sessionExpiry;
  final TokenManager? _tokenManagerOverride;

  /// Waits for the user's profile to load, so the sign-in loader stays up until then.
  final Future<void> Function() _waitForProfile;
  TokenManager get _tokens => _tokenManagerOverride ?? TokenManager();
  StreamSubscription<User?>? _authStateSubscription;

  // --------------------------------------------------------------------------
  // |                               Initialization & Lifecycle               |
  // --------------------------------------------------------------------------

  AuthController({
    required AuthRepository repository,
    required SessionLifecycleService sessionLifecycleService,
    required FirebaseAuth firebaseAuth,
    required ConnectivityService connectivity,
    required MutationSyncManager syncManager,
    required AppDatabase db,
    required SessionExpiry sessionExpiry,
    TokenManager? tokenManager,
    Future<void> Function()? waitForProfile,
  })  : _repository = repository,
        _waitForProfile = waitForProfile ?? (() async {}),
        _tokenManagerOverride = tokenManager,
        _sessionExpiry = sessionExpiry,
        _sessionLifecycleService = sessionLifecycleService,
        _firebaseAuth = firebaseAuth,
        _connectivity = connectivity,
        _syncManager = syncManager,
        _db = db {
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
        _firebaseAuth.authStateChanges().listen((user) async {
      if (user == null) {
        _updateState(_state.copyWith(
          currentUser: null,
          isInitialized: true,
        ));
        await _flushPendingMutations();
        try {
          _sessionLifecycleService.endSession();
        } catch (_) {}
      } else {
        _updateState(_state.copyWith(
          currentUser: user,
          isInitialSyncInProgress: true,
          isInitialized: false,
        ));

        try {
          await _refreshAuthAndProfile(user);
        } finally {
          _updateState(_state.copyWith(
            isInitialSyncInProgress: false,
            isInitialized: true,
          ));
          await _waitForProfile();
          GlobalAsyncLoader.hide();
        }
      }
    });
  }

  // --------------------------------------------------------------------------
  // |                                   Actions & Methods                    |
  // --------------------------------------------------------------------------

  Future<void> _flushPendingMutations() async {
    try {
      if (!await _connectivity.isConnected) return;
      await _syncManager.triggerSync().timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Best-effort pre-session-end sync failed or timed out: $e');
    }
  }

  Future<void> _refreshAuthAndProfile(User user) async {
    try {
      await user.reload().timeout(const Duration(seconds: 5));
      if (_firebaseAuth.currentUser == null) {
        _sessionExpiry.markExpired();
        return;
      }
    } on FirebaseAuthException catch (e) {
      // Lock instead of signing out, so unsynced data survives until the user chooses.
      if (e.code == 'user-not-found' ||
          e.code == 'user-disabled' ||
          e.code == 'user-token-expired') {
        _sessionExpiry.markExpired();
        return;
      }
    } catch (_) {}

    try {
      await _sessionLifecycleService.startSession(user.uid);
    } catch (e) {
      debugPrint('Error starting session: $e');
    }
  }

  /// Whether "Sign in again" needs a password field.
  bool get reauthNeedsPassword => _repository.usesPassword;

  /// Signs the same user in again after their session expired; returns an error message, or null.
  Future<String?> reauthenticate({String? password}) async {
    final result = await _repository.reauthenticate(password: password);
    return result.fold((error) => error, (_) async {
      _sessionExpiry.clear();
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null) await _sessionLifecycleService.startSession(uid);
      return null;
    });
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
      (_) {},
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
      (_) {},
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
      (_) {},
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
      (_) {},
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
        try {
          await _sessionLifecycleService.endSession();
        } catch (e) {
          debugPrint('Error ending session on delete: $e');
        }
        await _tokens.clearTokens();
        GlobalAsyncLoader.hide();
        if (context.mounted) {
          AppSnackBar.showSuccess(context,
              message: 'Account successfully deleted.');
        }
      },
    );
  }

  /// Tries to send queued changes, then reports what a logout would still lose.
  Future<({int waiting, int failed})> syncBeforeLogout() async {
    try {
      if (await _connectivity.isConnected) {
        await _syncManager.triggerSync().timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      debugPrint('Sync before logout failed or timed out: $e');
    }
    final dao = _db.pendingMutationsDao;
    return (
      waiting: (await dao.getAllPendingMutations()).length,
      failed: (await dao.getFailedMutations()).length,
    );
  }

  /// Logs out: ends the session (FCM token, reminders, wipe), then signs out of Firebase.
  /// Callers warn about unsynced changes first (see `logOutWithSyncCheck`).
  /// Firebase sign-out only happens once the wipe really emptied the database.
  Future<void> signOut(BuildContext context) async {
    GlobalAsyncLoader.show(context, message: "Signing out...");

    try {
      await _sessionLifecycleService.endSession();
    } catch (e) {
      debugPrint('Error ending session on sign out: $e');
    }

    // A failed wipe must not hand this phone's data to the next user.
    try {
      if (await _db.hasAnyRows()) await _db.wipeAll();
    } catch (e) {
      debugPrint('Retrying the wipe failed: $e');
    }
    if (await _db.hasAnyRows().catchError((_) => true)) {
      GlobalAsyncLoader.hide();
      AppSnackBar.showError(context.mounted ? context : null,
          message: "We couldn't finish logging out. Please try again.");
      return;
    }

    final result = await _repository.signOut();
    await _tokens.clearTokens();

    GlobalAsyncLoader.hide();

    result.fold(
      (error) => _showError(context.mounted ? context : null, error),
      (_) {
        AppSnackBar.showSuccess(context.mounted ? context : null,
            message: 'Successfully signed out.');
      },
    );
  }

  void _showError(BuildContext? context, String message) {
    if (message == 'User cancelled the operation.' ||
        message == 'Sign in cancelled' ||
        message == 'Apple sign-in cancelled' ||
        message == 'Re-authentication was cancelled.') {
      return; // Silent failure for user cancellations
    }
    AppSnackBar.showError(context != null && context.mounted ? context : null,
        message: message);
  }
}
