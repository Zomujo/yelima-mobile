import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../managers/token_manager.dart';
import '../../services/session_expiry.dart';
import '../../utils/logger.dart';

/// Adds the Firebase token to requests and recovers from 401s with one shared token refresh.
///
/// It never signs the user out: a login that can't be refreshed locks the app
/// through [SessionExpiry], so unsynced data survives until the user decides.
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;
  final Dio _dio;
  final FirebaseAuth? _authOverride;
  final SessionExpiry? _sessionExpiry;

  AuthInterceptor({
    TokenManager? tokenManager,
    required Dio dio,
    FirebaseAuth? firebaseAuth,
    SessionExpiry? sessionExpiry,
  })  : _tokenManager = tokenManager ?? TokenManager(),
        _dio = dio,
        _authOverride = firebaseAuth,
        _sessionExpiry = sessionExpiry;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  // A Completer used to serialize concurrent token fetch operations.
  Completer<String?>? _tokenCompleter;

  // The token refresh in progress, shared by concurrent 401s.
  Future<String?>? _refreshing;

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
    if (err.response?.statusCode != 401) return handler.next(err);

    // The retry with a fresh token was refused too: the login is no longer valid.
    if (err.requestOptions.extra['isRetry'] == true) {
      await _expire('401 after token refresh');
      return handler.next(err);
    }

    final token = await (_refreshing ??=
        _refreshToken().whenComplete(() => _refreshing = null));
    if (token == null) return handler.next(err);

    final options = err.requestOptions
      ..headers['Authorization'] = 'Bearer $token'
      ..extra['isRetry'] = true;
    try {
      return handler.resolve(await _dio.fetch(options));
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  /// Forces a token refresh; null when there is no user or the refresh failed.
  Future<String?> _refreshToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken(true);
    } on FirebaseAuthException catch (e) {
      // Offline: keep the session and let the request fail as a network error.
      if (e.code != 'network-request-failed') await _expire(e.code);
      return null;
    } catch (e) {
      AppLogger.e('AuthInterceptor: Token refresh failed', e);
      return null;
    }
  }

  Future<void> _expire(String reason) async {
    AppLogger.w('AuthInterceptor: Session expired ($reason). Locking the app.');
    await _tokenManager.clearTokens().catchError((_) {});
    _sessionExpiry?.markExpired();
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
