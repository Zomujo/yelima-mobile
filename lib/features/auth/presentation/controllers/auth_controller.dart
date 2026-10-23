import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../core/services/session_expiry.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Tracks who is signed in and runs sign-in, logout and account deletion.
class AuthController extends ChangeNotifier with SafeNotifier {
  AuthController({
    required AuthRepository repository,
    required SessionLifecycleService session,
    required MutationSyncManager syncManager,
    required SessionExpiry sessionExpiry,
    Future<void> Function(AuthUser? user)? onUserChanged,
  })  : _repository = repository,
        _session = session,
        _sync = syncManager,
        _sessionExpiry = sessionExpiry,
        _onUserChanged = onUserChanged ?? ((_) async {}) {
    _subscription = _repository.watchUser().listen(_onAuthChanged);
  }

  final AuthRepository _repository;
  final SessionLifecycleService _session;
  final MutationSyncManager _sync;
  final SessionExpiry _sessionExpiry;
  final Future<void> Function(AuthUser? user) _onUserChanged;
  late final StreamSubscription<AuthUser?> _subscription;
  Completer<void>? _loginReady;

  AuthState _state = const AuthState();
  AuthState get state => _state;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isInitialized => _state.isInitialized;
  bool get isAuthLoading => _state.isAuthLoading;
  bool get isInitialSyncInProgress => _state.isInitialSyncInProgress;

  /// Whether "Sign in again" needs a password field.
  bool get reauthNeedsPassword => _repository.usesPassword;

  void _update(AuthState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> _onAuthChanged(AuthUser? user) async {
    if (user == null) {
      await _onUserChanged(null);
      _update(_state.copyWith(currentUser: null, isInitialized: true));
      await _sync.flush();
      await _session.endSession();
      return;
    }
    _update(_state.copyWith(
        currentUser: user,
        isInitialSyncInProgress: true,
        isInitialized: false));
    try {
      // The profile loads before auth reports ready, so the router never sees half a login.
      await Future.wait([_resumeSession(user), _onUserChanged(user)]);
    } finally {
      _update(
          _state.copyWith(isInitialSyncInProgress: false, isInitialized: true));
      if (_loginReady?.isCompleted == false) _loginReady!.complete();
    }
  }

  /// Starts the session, or locks the app if the login was revoked (unsynced data survives).
  Future<void> _resumeSession(AuthUser user) async {
    final login = await _repository.refreshLogin();
    if (login case Left(value: UnauthorizedFailure())) {
      return _sessionExpiry.markExpired();
    }
    await _session.startSession(user.uid);
  }

  /// Signs in with email.
  AsyncResult<void> signIn(String email, String password) =>
      _authenticate(() => _repository.signIn(email, password));

  /// Creates an email account.
  AsyncResult<void> register(String email, String password) =>
      _authenticate(() => _repository.register(email, password));

  /// Signs in with Google.
  AsyncResult<void> signInWithGoogle() =>
      _authenticate(_repository.signInWithGoogle);

  /// Signs in with Apple.
  AsyncResult<void> signInWithApple() =>
      _authenticate(_repository.signInWithApple);

  /// One attempt at a time; completes once the profile has loaded, so the loader covers it.
  AsyncResult<void> _authenticate(AsyncResult<void> Function() call) async {
    if (_state.isAuthLoading) return left(const CancelledFailure());
    _update(_state.copyWith(isAuthLoading: true));
    final ready = _loginReady = Completer<void>();
    final result = await call();
    if (result.isRight()) {
      await ready.future.timeout(const Duration(seconds: 30), onTimeout: () {});
    }
    _loginReady = null;
    _update(_state.copyWith(isAuthLoading: false));
    return result;
  }

  /// Sends a password reset link.
  AsyncResult<void> sendPasswordResetEmail(String email) =>
      _repository.sendPasswordResetEmail(email);

  /// Signs the same user in again after their session expired.
  AsyncResult<void> reauthenticate({String? password}) async {
    final result = await _repository.reauthenticate(password: password);
    final uid = _repository.currentUser?.uid;
    if (result.isRight() && uid != null) {
      _sessionExpiry.clear();
      await _session.startSession(uid);
    }
    return result;
  }

  /// Deletes the account; on success the session ends and local data is wiped.
  AsyncResult<void> deleteAccount({String? password}) async {
    final result = await _repository.deleteAccount(password: password);
    if (result.isRight()) await _session.endSession();
    return result;
  }

  /// Tries to send queued changes, then reports what a logout would still lose.
  Future<({int waiting, int failed})> syncBeforeLogout() => _sync.flush();

  /// Ends the session, then signs out; false (still signed in) if local data couldn't be wiped.
  Future<bool> signOut() async {
    await _session.endSession();
    return (await _repository.signOut()).isRight();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
