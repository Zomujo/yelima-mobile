import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/guard.dart';
import '../../../../core/managers/token_manager.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Firebase-backed [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
    required this.notifications,
    TokenManager? tokens,
  }) : _tokens = tokens ?? TokenManager();

  final AuthRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;
  final NotificationService notifications;
  final TokenManager _tokens;

  static AuthUser? _toAuthUser(User? user) =>
      user == null ? null : AuthUser(uid: user.uid, email: user.email);

  @override
  Stream<AuthUser?> watchUser() =>
      remoteDataSource.authStateChanges.map(_toAuthUser);

  @override
  AuthUser? get currentUser => _toAuthUser(remoteDataSource.currentUser);

  @override
  bool get usesPassword => remoteDataSource.usesPassword;

  @override
  AsyncResult<void> refreshLogin() => guard(remoteDataSource.reloadUser);

  @override
  AsyncResult<void> signIn(String email, String password) => guardOnline(
      connectivityService,
      () => remoteDataSource.signInWithEmail(email, password));

  @override
  AsyncResult<void> register(String email, String password) => guardOnline(
      connectivityService,
      () => remoteDataSource.signUpWithEmail(email, password));

  @override
  AsyncResult<void> signInWithGoogle() =>
      guardOnline(connectivityService, remoteDataSource.signInWithGoogle);

  @override
  AsyncResult<void> signInWithApple() =>
      guardOnline(connectivityService, remoteDataSource.signInWithApple);

  @override
  AsyncResult<void> sendPasswordResetEmail(String email) => guardOnline(
      connectivityService,
      () => remoteDataSource.sendPasswordResetEmail(email));

  @override
  AsyncResult<void> signOut() => guard(() async {
        // The session wipe may have failed; a leftover row must not reach the next user.
        if (await db.hasAnyRows()) await db.wipeAll();
        if (await db.hasAnyRows()) throw const StorageFailure();
        await notifications.cancelAllReminders();
        await remoteDataSource.signOut();
        await _tokens.clearTokens();
      });

  @override
  AsyncResult<void> deleteAccount({String? password}) =>
      guardOnline(connectivityService, () async {
        await remoteDataSource.deleteAccount(password: password);
        await _tokens.clearTokens();
      });

  @override
  AsyncResult<void> reauthenticate({String? password}) => guardOnline(
      connectivityService,
      () => remoteDataSource.reauthenticate(password: password));
}
