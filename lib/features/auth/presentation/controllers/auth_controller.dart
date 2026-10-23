import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yelima/core/managers/token_manager.dart';

import '../../../../shared/widgets/loaders/global_async_loader.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/services/session_expiry.dart';
import 'auth_state.dart';
import '../../../../core/utils/safe_notifier.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/utils/custom_types.dart';

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

  /// Loads or clears the user's profile; the one place login changes reach the profile.
  final Future<void> Function(User? user) _onUserChanged;
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
    Future<void> Function(User? user)? onUserChanged,
  })  : _repository = repository,
        _onUserChanged = onUserChanged ?? ((_) async {}),
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
        await _onUserChanged(null);
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
          // The profile loads before auth reports ready, so the router never sees a half-loaded login.
          await Future.wait(
              [_refreshAuthAndProfile(user), _onUserChanged(user)]);
        } finally {
          _updateState(_state.copyWith(
            isInitialSyncInProgress: false,
            isInitialized: true,
          ));
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

  /// Signs in with email. An empty error means the user cancelled.
  AsyncResponse<void> signIn(String email, String password) =>
      _authenticate(() => _repository.signIn(email, password));

  /// Creates an email account. An empty error means the user cancelled.
  AsyncResponse<void> register(String email, String password) =>
      _authenticate(() => _repository.register(email, password));

  /// Signs in with Google. An empty error means the user cancelled.
  AsyncResponse<void> signInWithGoogle() =>
      _authenticate(_repository.signInWithGoogle);

  /// Signs in with Apple. An empty error means the user cancelled.
  AsyncResponse<void> signInWithApple() =>
      _authenticate(_repository.signInWithApple);

  /// Runs one sign-in attempt at a time; success is finished by the auth listener.
  AsyncResponse<void> _authenticate(AsyncResponse<void> Function() call) async {
    if (_state.isAuthLoading) return left('');
    _updateState(_state.copyWith(isAuthLoading: true));
    final result = await call();
    _updateState(_state.copyWith(isAuthLoading: false));
    return result.mapLeft(_userFacing);
  }

  /// Sends a password reset link.
  AsyncResponse<void> sendPasswordResetEmail(String email) async =>
      (await _repository.sendPasswordResetEmail(email)).mapLeft(_userFacing);

  /// Deletes the account; on success the session ends and local data is wiped.
  AsyncResponse<void> deleteAccount({String? password}) async {
    final result = await _repository.deleteAccount(password: password);
    if (result.isRight()) {
      try {
        await _sessionLifecycleService.endSession();
      } catch (e) {
        debugPrint('Error ending session on delete: $e');
      }
      await _tokens.clearTokens();
    }
    return result.mapLeft(_userFacing);
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
  /// Returns false, still signed in, if the wipe didn't empty the database.
  Future<bool> signOut() async {
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
    if (await _db.hasAnyRows().catchError((_) => true)) return false;

    final result = await _repository.signOut();
    await _tokens.clearTokens();
    return result.isRight();
  }

  /// Hides user cancellations: they come back as an empty error.
  String _userFacing(String message) => const {
        'User cancelled the operation.',
        'Sign in cancelled',
        'Apple sign-in cancelled',
        'Re-authentication was cancelled.',
      }.contains(message)
          ? ''
          : message;
}
