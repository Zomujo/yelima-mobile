import 'dart:async';
import 'package:dio/dio.dart';
import '../../managers/token_manager.dart';
import '../../utils/logger.dart';

class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AuthInterceptor({TokenManager? tokenManager})
      : _tokenManager = tokenManager ?? TokenManager();

  // A Completer used to serialize concurrent token fetch operations.
  // If a fetch is already in progress, new requests wait for it to finish
  // rather than firing their own parallel fetch.
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

  /// Fetches a valid token, deduplicating concurrent calls via a Completer.
  /// If a token fetch is already in progress, this method waits for it to
  /// complete and returns the same token to all waiting callers.
  Future<String?> _getToken() async {
    if (_tokenCompleter != null && !_tokenCompleter!.isCompleted) {
      // Another request is already fetching a token — piggyback on it.
      AppLogger.d('AuthInterceptor: token fetch in progress, waiting...');
      return _tokenCompleter!.future;
    }

    _tokenCompleter = Completer<String?>();

    try {
      final token = await _tokenManager.getValidAuthToken();
      _tokenCompleter!.complete(token);
      return token;
    } catch (e) {
      _tokenCompleter!.completeError(e);
      rethrow;
    } finally {
      // Clear so the next request starts fresh.
      _tokenCompleter = null;
    }
  }
}
