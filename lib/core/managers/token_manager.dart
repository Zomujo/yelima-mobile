import 'package:yelima/core/constants/cache_keys.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../services/fcm_token_service.dart';
import '../utils/logger.dart';

// Manages retrieval of authentication and FCM tokens.
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  
  
  String? _cachedAuthToken;
  String? _cachedFCMToken;
  StreamSubscription? _tokenRefreshSubscription;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Auth Token
  // ---------------------------------------------------------------------------

  // Retrieves the current Firebase Auth JWT token.
  Future<String?> getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken(false);
    }
    return null;
  }

  // Retrieves a valid auth token, falling back to cache when offline.
  Future<String?> getValidAuthToken() async {
    try {
      _cachedAuthToken ??= await _secureStorage.read(key: CacheKeys.authToken);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken(false);

      if (token != _cachedAuthToken) {
        _cachedAuthToken = token;
        await _secureStorage.write(key: CacheKeys.authToken, value: token!);
      }
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

  // Fetches the device FCM token.
  Future<String?> getFCMToken() async {
    // Restore cached token from storage first
    _cachedFCMToken = await _secureStorage.read(key: CacheKeys.fcmToken);
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
          AppLogger.w(
              'TokenManager: Waiting for APNs token (Attempt $retryCount/$maxRetries)...');
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (apnsToken == null) {
        AppLogger.w(
            'TokenManager: APNs token still null after $maxRetries attempts — FCM token may be unavailable.');
      }
    }

    // Get the current FCM token from Firebase
    final currentToken = await _firebaseMessaging.getToken();
    if (currentToken != null && currentToken != _cachedFCMToken) {
      _cachedFCMToken = currentToken;
      await _secureStorage.write(key: CacheKeys.fcmToken, value: currentToken);
      AppLogger.i('TokenManager: FCM token updated and saved.');
    }

    // Listen for future token refreshes — cancel any previous listener first
    // to prevent duplicate subscription leaks across multiple sessions.
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription =
        _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      AppLogger.i('TokenManager: FCM token refreshed.');
      _cachedFCMToken = newToken;
      await _secureStorage.write(key: CacheKeys.fcmToken, value: newToken);

      try {
        if (GetIt.instance.isRegistered<FCMTokenService>()) {
          GetIt.instance<FCMTokenService>()
              .registerFCMToken()
              .catchError((_) {});
        }
      } catch (_) {}
    });

    return _cachedFCMToken;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  // Clears all cached tokens.
  Future<void> clearTokens() async {
    _cachedAuthToken = null;
    _cachedFCMToken = null;
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    await _secureStorage.delete(key: CacheKeys.fcmToken);
    await _secureStorage.delete(key: CacheKeys.authToken);
    AppLogger.d('TokenManager: All tokens cleared.');
  }

  // Alias for clearTokens.
  Future<void> clearToken() => clearTokens();

  // No-op
  Future<void> saveTokens(
      {required String auth, required String refresh}) async {}

  // No-op
  Future<String?> getRefreshToken() async => null;
}
