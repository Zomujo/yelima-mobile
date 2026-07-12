import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../managers/token_manager.dart';
import '../../utils/logger.dart';

class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AuthInterceptor({TokenManager? tokenManager})
      : _tokenManager = tokenManager ?? TokenManager();

  // A Completer used to serialize concurrent token fetch operations.
  Completer<String?>? _tokenCompleter;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      AppLogger.e('Error in AuthInterceptor: $e');
    }

    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (err.requestOptions.extra['isRetry'] == true) {
        AppLogger.w('AuthInterceptor: 401 Unauthorized received on RETRY. Logging out user.');
        try {
          await FirebaseAuth.instance.signOut();
        } catch (e) {
          AppLogger.e('AuthInterceptor: Error signing out on 401', e);
        }
        return handler.next(err);
      }

      AppLogger.w('AuthInterceptor: 401 Unauthorized received. Attempting to force refresh token...');
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final newToken = await user.getIdToken(true);
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';
          options.extra['isRetry'] = true;

          final dio = Dio();
          final response = await dio.fetch(options);
          return handler.resolve(response);
        }
      } catch (e) {
        AppLogger.e('AuthInterceptor: Force refresh failed', e);
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
      }
    }
    handler.next(err);
  }

  /// Fetches a valid token, deduplicating concurrent calls via a Completer.
  Future<String?> _getToken() async {
    if (_tokenCompleter != null && !_tokenCompleter!.isCompleted) {
      AppLogger.d('AuthInterceptor: token fetch in progress, waiting...');
      return _tokenCompleter!.future;
    }

    _tokenCompleter = Completer<String?>();

    try {
      final token = await _tokenManager.getValidAuthToken();
      _tokenCompleter!.complete(token);
      return token;
    } catch (e, stackTrace) {
      if (!_tokenCompleter!.isCompleted) {
        _tokenCompleter!.completeError(e, stackTrace);
      }
      rethrow;
    } finally {
      // Clear so the next request starts fresh.
      _tokenCompleter = null;
    }
  }
}
