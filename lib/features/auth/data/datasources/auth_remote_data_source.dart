import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/failures/app_failure.dart';

/// Talks to Firebase Auth, Google, Apple and the account API.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required APIClient apiClient,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth,
        _api = apiClient,
        _google = googleSignIn ?? GoogleSignIn(scopes: ['email']),
        _firestoreOverride = firestore;

  final FirebaseAuth _auth;
  final APIClient _api;
  final GoogleSignIn _google;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  /// Emits on sign-in and sign-out only.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Whether the user logs in with email and password.
  bool get usesPassword =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'password') ??
      false;

  /// Reloads the user; throws [UnauthorizedFailure] if the login was revoked.
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload().timeout(const Duration(seconds: 5));
    } on FirebaseAuthException catch (e) {
      const revoked = {'user-not-found', 'user-disabled', 'user-token-expired'};
      if (revoked.contains(e.code)) throw const UnauthorizedFailure();
      rethrow;
    }
    if (_auth.currentUser == null) throw const UnauthorizedFailure();
  }

  /// Signs in with email and password.
  Future<void> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  /// Creates an email account.
  Future<void> signUpWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  /// Signs in with Google.
  Future<void> signInWithGoogle() async =>
      _auth.signInWithCredential(await _googleCredential());

  /// Signs in with Apple.
  Future<void> signInWithApple() async =>
      _auth.signInWithCredential(await _appleCredential());

  /// Sends a password reset link.
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// Signs out of Firebase and Google.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      if (await _google.isSignedIn()) _google.signOut(),
    ]);
  }

  /// Confirms the user's identity again with the provider they signed in with.
  Future<User> reauthenticate({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw const UnauthorizedFailure();
    final providers = user.providerData.map((p) => p.providerId).toSet();

    final AuthCredential credential;
    if (providers.contains('password')) {
      if (password == null || password.isEmpty) {
        throw const AuthFailure(AuthError.wrongPassword);
      }
      credential =
          EmailAuthProvider.credential(email: user.email!, password: password);
    } else if (providers.contains('google.com')) {
      await _google.signOut(); // Forces the account picker.
      credential = await _googleCredential();
    } else {
      credential = await _appleCredential();
    }
    await user.reauthenticateWithCredential(credential);
    return user;
  }

  /// Deletes in an order where any failure leaves the account usable and retryable:
  /// identity, server data, profile doc, then the login itself.
  Future<void> deleteAccount({String? password}) async {
    final user = await reauthenticate(password: password);
    await _api.delete('api/v1/client/clean');
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
    if (await _google.isSignedIn()) await _google.signOut();
  }

  Future<OAuthCredential> _googleCredential() async {
    final account = await _google.signIn();
    if (account == null) throw const UserCanceledException();
    final auth = await account.authentication;
    return GoogleAuthProvider.credential(
        accessToken: auth.accessToken, idToken: auth.idToken);
  }

  Future<OAuthCredential> _appleCredential() async {
    final apple = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ]);
    return OAuthProvider('apple.com').credential(
        idToken: apple.identityToken, accessToken: apple.authorizationCode);
  }
}
