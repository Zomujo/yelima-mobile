import '../api/api_client.dart';
import '../managers/token_manager.dart';
import '../utils/logger.dart';

class FCMTokenService {
  final APIClient _apiClient;
  late final TokenManager _tokenManager;

  /// In-memory cache of the last registered FCM token.
  /// Populated on [registerFCMToken] so [deleteFCMToken] can use it
  /// even after TokenManager/SharedPreferences have been cleared during logout.
  String? _registeredToken;

  FCMTokenService(this._apiClient) {
    _tokenManager = TokenManager();
  }

  Future<void> registerFCMToken() async {
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
      _registeredToken = token;

      AppLogger.i('FCM token successfully registered with backend: $token');
    } catch (e) {
      AppLogger.w('Failed to register FCM token: $e');
      rethrow;
    }
  }

  Future<void> deleteFCMToken() async {
    try {
      // Prefer the in-memory cached token — it's guaranteed to be available
      // even after TokenManager.clearTokens() has already run.
      // Fall back to TokenManager only if we somehow never registered.
      final String? token;
      if (_registeredToken != null) {
        token = _registeredToken;
        AppLogger.d(
            'FCMTokenService: Using in-memory cached token for deletion.');
      } else {
        final stored = await _tokenManager.getFCMToken();
        token = stored?.replaceAll('"', '');
      }

      if (token == null) {
        AppLogger.i('No FCM token found to delete. Skipping backend deletion.');
        return;
      }

      final auth = await _tokenManager.getValidAuthToken();
      AppLogger.w('DEBUG: Is Auth Token null? ${auth == null}');
      AppLogger.w('DEBUG: Sending FCM Token: $token');

      await _apiClient.delete(
        'api/v1/chronic-care/notifications/fcm-tokens',
        data: {'fcmToken': token},
      );

      _registeredToken = null; // Clear the cache after successful deletion
      AppLogger.i('FCM token successfully deleted from backend: $token');
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      // 404 → token already gone. 401 → session already ended (auth cleared
      // before this call). Both are non-fatal during logout.
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
