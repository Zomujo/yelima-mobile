import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/exceptions/exceptions.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

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

  Future<void> deleteAccount({String? password}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const UnauthenticatedException();

    /// Reauthenticate based on provider.
    final isPassword = user.providerData.any((p) => p.providerId == 'password');
    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
    final isApple = user.providerData.any((p) => p.providerId == 'apple.com');

    if (isPassword) {
      if (password == null || password.isEmpty) {
        throw const ErrorException(
            message: 'Password is required to delete account');
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

    /// Delete the user document from Firestore.
    await _firestore.collection('users').doc(user.uid).delete();

    /// Delete user from Firebase Auth.
    await user.delete();
    await _googleSignIn.signOut();
  }
}
