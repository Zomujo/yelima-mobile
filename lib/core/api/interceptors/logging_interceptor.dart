import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  Map<String, dynamic> _redactedHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    if (copy.containsKey('Authorization')) copy['Authorization'] = '[REDACTED]';
    return copy;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('🚀 [API] REQUEST[${options.method}] => PATH: ${options.uri}');
      debugPrint('Headers: ${_redactedHeaders(options.headers)}');
      debugPrint('Body: ${options.data}');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
          '✅ [API] RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.uri}');
      debugPrint('Data: ${response.data}');
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Suppress verbose console spam for expected FCM token deletion errors during logout.
    // The FCMTokenService already handles these gracefully via an INFO log.
    final isFcmEndpoint = err.requestOptions.path.contains('fcm-tokens');
    final isExpectedAuthError = err.response?.statusCode == 401 || err.response?.statusCode == 404;

    if (kDebugMode && !(isFcmEndpoint && isExpectedAuthError)) {
      debugPrint(
          '❌ [API] ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      debugPrint('Message: ${err.message}');

      // Placeholder for MonitoringService (Firebase Crashlytics, etc.)
      if (err.response != null && err.response!.statusCode! >= 500) {
        // MonitoringService.instance.recordError(err, err.stackTrace);
      }
    }

    return super.onError(err, handler);
  }
}
