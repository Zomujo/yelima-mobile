import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

/// Manages retrieval of authentication and FCM tokens.
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  static const String _fcmTokenKey = 'cached_fcm_token';
  String? _cachedAuthToken;
  String? _cachedFCMToken;
  final _firebaseMessaging = FirebaseMessaging.instance;

  // ---------------------------------------------------------------------------
  // Auth Token
  // ---------------------------------------------------------------------------

  /// Retrieves the current Firebase Auth JWT token.
  /// Firebase automatically handles refreshing the token if it's expired.
  Future<String?> getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken(false);
    }
    return null;
  }

  /// Retrieves a valid auth token, using the in-memory cache as a fallback
  /// when there's no network. Firebase SDK refreshes it automatically if needed.
  Future<String?> getValidAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken(false);
      _cachedAuthToken = token;
      return token;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed' && _cachedAuthToken != null) {
        AppLogger.w('TokenManager: Offline — returning cached auth token.');
        return _cachedAuthToken;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // FCM Token
  // ---------------------------------------------------------------------------

  /// Fetches the device FCM token from Firebase Messaging.
  ///
  /// On iOS, waits for the APNs token to be available first (up to 5 retries)
  /// before requesting the FCM token, as FCM requires APNs to be ready.
  /// Caches the token in SharedPreferences and listens for refreshes.
  Future<String?> getFCMToken() async {
    // Restore cached token from storage first
    final prefs = await SharedPreferences.getInstance();
    _cachedFCMToken = prefs.getString(_fcmTokenKey);
    if (_cachedFCMToken != null) {
      AppLogger.d('TokenManager: Restored cached FCM token from storage.');
    }

    // On iOS, wait for APNs token before getting FCM token
    if (Platform.isIOS) {
      String? apnsToken;
      int retryCount = 0;
      const maxRetries = 5;

      while (apnsToken == null && retryCount < maxRetries) {
        apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          retryCount++;
          AppLogger.w('TokenManager: Waiting for APNs token (Attempt $retryCount/$maxRetries)...');
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (apnsToken == null) {
        AppLogger.w('TokenManager: APNs token still null after $maxRetries attempts — FCM token may be unavailable.');
      }
    }

    // Get the current FCM token from Firebase
    final currentToken = await _firebaseMessaging.getToken();
    if (currentToken != null && currentToken != _cachedFCMToken) {
      _cachedFCMToken = currentToken;
      await prefs.setString(_fcmTokenKey, currentToken);
      AppLogger.i('TokenManager: FCM token updated and saved.');
    }

    // Listen for future token refreshes
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      AppLogger.i('TokenManager: FCM token refreshed.');
      _cachedFCMToken = newToken;
      final p = await SharedPreferences.getInstance();
      await p.setString(_fcmTokenKey, newToken);
    });

    return _cachedFCMToken;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Clears all cached tokens (call on sign out).
  Future<void> clearTokens() async {
    _cachedAuthToken = null;
    _cachedFCMToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fcmTokenKey);
    AppLogger.d('TokenManager: All tokens cleared.');
  }

  /// Alias for [clearTokens].
  Future<void> clearToken() => clearTokens();

  /// No-op — Firebase handles token storage internally.
  Future<void> saveTokens({required String auth, required String refresh}) async {}

  /// No-op — Firebase handles refresh token internally.
  Future<String?> getRefreshToken() async => null;
}
