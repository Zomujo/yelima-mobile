import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../managers/token_manager.dart';
import '../../utils/logger.dart';

class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;
  final Dio _dio;

  AuthInterceptor({TokenManager? tokenManager, required Dio dio})
      : _tokenManager = tokenManager ?? TokenManager(),
        _dio = dio;

  // A Completer used to serialize concurrent token fetch operations.
  Completer<String?>? _tokenCompleter;

  // A Completer to serialize concurrent token refresh operations on 401.
  Completer<bool>? _refreshCompleter;

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
        AppLogger.w(
            'AuthInterceptor: 401 Unauthorized received on RETRY. Logging out user.');
        try {
          await FirebaseAuth.instance.signOut();
        } catch (e) {
          AppLogger.e('AuthInterceptor: Error signing out on 401', e);
        }
        return handler.next(err);
      }

      if (_refreshCompleter != null) {
        // Wait for the in-progress refresh
        AppLogger.d('AuthInterceptor: Token refresh in progress, waiting...');
        final success = await _refreshCompleter!.future;
        if (success) {
          final token = await _tokenManager.getAuthToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          err.requestOptions.extra['isRetry'] = true;
          try {
            final response = await _dio.fetch(err.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(err);
          }
        } else {
          return handler.next(err);
        }
      }

      _refreshCompleter = Completer<bool>();
      AppLogger.w(
          'AuthInterceptor: 401 Unauthorized received. Attempting to force refresh token...');
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final newToken = await user.getIdToken(true);
          _refreshCompleter!.complete(true);
          
          // Debounce to prevent stampede of concurrent 401s triggering another refresh
          Future.delayed(const Duration(seconds: 2), () {
            _refreshCompleter = null;
          });

          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';
          options.extra['isRetry'] = true;

          try {
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          } on DioException catch (retryErr) {
            return handler.next(retryErr);
          } catch (e) {
            return handler.next(err);
          }
        } else {
          _refreshCompleter!.complete(false);
          _refreshCompleter = null;
        }
      } catch (e) {
        AppLogger.e('AuthInterceptor: Force refresh failed', e);
        if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
          _refreshCompleter!.complete(false);
          Future.delayed(const Duration(seconds: 2), () {
            _refreshCompleter = null;
          });
        }
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
        return handler.next(err);
      }
    } else {
      handler.next(err);
    }
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
