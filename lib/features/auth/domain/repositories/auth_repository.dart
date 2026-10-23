import '../../../../core/failures/app_failure.dart';
import '../entities/auth_user.dart';

/// Sign-in, sign-out and account actions.
abstract class AuthRepository {
  /// Emits the signed-in user on every sign-in and null on sign-out.
  Stream<AuthUser?> watchUser();

  /// The signed-in user, or null.
  AuthUser? get currentUser;

  /// Whether re-authentication needs a password rather than Google or Apple.
  bool get usesPassword;

  /// Checks the login is still valid; [UnauthorizedFailure] means it isn't.
  AsyncResult<void> refreshLogin();

  /// Signs in with email and password.
  AsyncResult<void> signIn(String email, String password);

  /// Creates an email account.
  AsyncResult<void> register(String email, String password);

  /// Signs in with Google.
  AsyncResult<void> signInWithGoogle();

  /// Signs in with Apple.
  AsyncResult<void> signInWithApple();

  /// Sends a password reset link.
  AsyncResult<void> sendPasswordResetEmail(String email);

  /// Wipes local data, then signs out; fails without signing out if the wipe fails.
  AsyncResult<void> signOut();

  /// Confirms identity, then deletes the account and its server data.
  AsyncResult<void> deleteAccount({String? password});

  /// Confirms the signed-in user again after their session expired.
  AsyncResult<void> reauthenticate({String? password});
}
