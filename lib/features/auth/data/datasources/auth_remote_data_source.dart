import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/exceptions/exceptions.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final APIClient _apiClient;

  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  AuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required APIClient apiClient,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth,
        _apiClient = apiClient,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']),
        _firestoreOverride = firestore;

  Stream<User?> get authStateChanges => _firebaseAuth.userChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signInWithEmail(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const UserCanceledException();
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled' || e.code == 'CANCELED') {
        throw const UserCanceledException();
      }
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const UserCanceledException();
      }
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      if (await _googleSignIn.isSignedIn()) _googleSignIn.signOut(),
    ]);
  }

  /// Confirms the signed-in user's identity again with their own provider, returning the user.
  Future<User> reauthenticate({String? password}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const UnauthenticatedException();

    /// Reauthenticate based on provider.
    final isPassword = user.providerData.any((p) => p.providerId == 'password');
    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
    final isApple = user.providerData.any((p) => p.providerId == 'apple.com');

    if (isPassword) {
      if (password == null || password.isEmpty) {
        throw const ErrorException(message: 'Password is required');
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } else if (isGoogle) {
      await _googleSignIn.signOut();
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw const ReauthenticationCancelledException();
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      } on PlatformException catch (e) {
        if (e.code == 'sign_in_canceled' || e.code == 'CANCELED') {
          throw const ReauthenticationCancelledException();
        }
        rethrow;
      }
    } else if (isApple) {
      try {
        final AuthorizationCredentialAppleID appleCredential =
            await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        final credential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );
        await user.reauthenticateWithCredential(credential);
      } on SignInWithAppleAuthorizationException catch (e) {
        if (e.code == AuthorizationErrorCode.canceled) {
          throw const ReauthenticationCancelledException();
        }
        rethrow;
      }
    }
    return user;
  }

  /// Whether the signed-in user logs in with email and password (so re-auth needs one).
  bool get usesPassword =>
      _firebaseAuth.currentUser?.providerData
          .any((p) => p.providerId == 'password') ??
      false;

  /// Deletes the account in an order where a failure leaves it usable and retryable:
  /// confirm identity, delete server data, then the profile doc, then the login itself.
  /// Each step stops on error; nothing signs the user out early.
  Future<void> deleteAccount({String? password}) async {
    final user = await reauthenticate(password: password);
    await _apiClient.delete('api/v1/client/clean');
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
    if (await _googleSignIn.isSignedIn()) await _googleSignIn.signOut();
  }
}
