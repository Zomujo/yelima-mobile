import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../managers/token_manager.dart';
import '../utils/logger.dart';

/// Sends the device's push token to the backend.
///
/// Retrying after a failed attempt (e.g. when back online) is up to
/// FCMLifecycleHandler, which knows whether anyone is signed in.
class FCMTokenService {
  final APIClient _apiClient;
  late final TokenManager _tokenManager;
  Future<void>? _registering;

  /// In-memory cache of the last registered FCM token.
  /// Populated on [registerFCMToken] so [deleteFCMToken] can use it
  /// even after TokenManager/SharedPreferences have been cleared during logout.
  String? _registeredToken;

  FCMTokenService(this._apiClient) {
    _tokenManager = TokenManager()
      ..onFcmTokenRefreshed =
          () => registerFCMToken(fresh: true).catchError((_) {});
  }

  /// Registers the token. A call while one is running joins it, unless
  /// [fresh] (a new session or a new token), which must not reuse the old one.
  Future<void> registerFCMToken({bool fresh = false}) {
    final running = _registering;
    if (running != null && !fresh) return running;
    late final Future<void> attempt;
    attempt = _register(isCurrent: () => identical(_registering, attempt))
        .whenComplete(() {
      if (identical(_registering, attempt)) _registering = null;
    });
    return _registering = attempt;
  }

  Future<void> _register({required bool Function() isCurrent}) async {
    try {
      final fcmToken = await _tokenManager.getFCMToken();

      if (fcmToken == null) {
        throw Exception('Failed to get FCM token');
      }

      final token = fcmToken.replaceAll('"', '');

      await _apiClient.post(
        'api/v1/chronic-care/notifications/fcm-tokens',
        data: {'fcmToken': token},
      );

      // Cache it in-memory so deleteFCMToken can use it even after
      // SharedPreferences / TokenManager have been cleared during logout.
      // A newer attempt (next session or token) owns the cache now.
      if (isCurrent()) _registeredToken = token;

      AppLogger.i('FCM token registered with backend.');
    } catch (e) {
      AppLogger.w('Failed to register FCM token: $e');
      rethrow;
    }
  }

  Future<void> deleteFCMToken() async {
    try {
      String? token;
      if (_registeredToken != null) {
        token = _registeredToken;
        AppLogger.d(
            'FCMTokenService: Using in-memory cached token for deletion.');
      } else {
        const secureStorage = FlutterSecureStorage();
        final stored = await secureStorage.read(key: "cached_fcm_token");
        token = stored?.replaceAll('"', '');
      }

      if (token == null) {
        AppLogger.i('No FCM token found to delete. Skipping backend deletion.');
        return;
      }

      await _apiClient.delete(
        'api/v1/chronic-care/notifications/fcm-tokens',
        data: {'fcmToken': token},
      );

      _registeredToken = null; // Clear the cache after successful deletion
      AppLogger.i('FCM token deleted from backend.');
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('404') ||
          errorString.contains('not found') ||
          errorString.contains('401') ||
          errorString.contains('unauthorized') ||
          errorString.contains('token absent')) {
        AppLogger.i(
            'FCM token deletion skipped (session already ended or token gone): $e');
        _registeredToken = null;
        return;
      }

      AppLogger.w('Failed to delete FCM token from backend: $e');
      rethrow;
    }
  }
}
