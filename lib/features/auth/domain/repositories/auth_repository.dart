import '../../../../core/utils/custom_types.dart';

abstract class AuthRepository {
  /// Signs in with Email and Password
  AsyncResponse<void> signIn(String email, String password);

  /// Registers a new user with Email and Password
  AsyncResponse<void> register(String email, String password);

  /// Signs in with Google
  AsyncResponse<void> signInWithGoogle();

  /// Signs in with Apple
  AsyncResponse<void> signInWithApple();

  /// Sends a password reset email
  AsyncResponse<void> sendPasswordResetEmail(String email);

  /// Signs out the user
  AsyncResponse<void> signOut();

  /// Deletes the user account, requiring re-authentication
  AsyncResponse<void> deleteAccount({String? password});
}
