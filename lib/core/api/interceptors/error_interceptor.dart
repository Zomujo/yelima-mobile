import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../managers/token_manager.dart';
import '../../utils/logger.dart';

class ErrorInterceptor extends Interceptor {
  static bool _isLoggingOut = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      if (!_isLoggingOut) {
        _isLoggingOut = true;
        AppLogger.w('401 Unauthorized detected. Triggering silent global logout.');
        TokenManager().clearToken();
        // Silently sign out to drop back to login via AuthController's stream
        FirebaseAuth.instance.signOut().catchError((e) {
          AppLogger.e('Failed to sign out silently from Firebase: $e');
        }).whenComplete(() {
          // Reset lock after a delay to allow UI to transition
          Future.delayed(const Duration(seconds: 3), () {
            _isLoggingOut = false;
          });
        });
      } else {
        AppLogger.w('401 Unauthorized detected but logout is already in progress.');
      }
    }

    // Safely remap the DioException to extract backend messages
    handler.next(
      DioException(
        message: err.response?.data is Map
            ? err.response?.data['message']
            : err.message,
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
      ),
    );
  }
}
