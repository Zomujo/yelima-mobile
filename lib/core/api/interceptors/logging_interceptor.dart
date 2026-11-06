import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../utils/logger.dart';

/// Logs requests and responses in debug builds, with secrets hidden.
class LoggingInterceptor extends Interceptor {
  static final _secret =
      RegExp('authorization|token|password|secret', caseSensitive: false);

  /// [data] with every value under a secret-looking key replaced.
  @visibleForTesting
  static Object? redact(Object? data) => switch (data) {
        Map() => {
            for (final MapEntry(:key, :value) in data.entries)
              key: _secret.hasMatch('$key') ? '[REDACTED]' : redact(value),
          },
        List() => [for (final item in data) redact(item)],
        _ => data,
      };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kLogsOn) {
      debugPrint('🚀 [API] REQUEST[${options.method}] => PATH: ${options.uri}');
      debugPrint('Headers: ${redact(options.headers)}');
      debugPrint('Body: ${redact(options.data)}');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kLogsOn) {
      debugPrint(
          '✅ [API] RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.uri}');
      debugPrint('Data: ${redact(response.data)}');
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Suppress verbose console spam for expected FCM token deletion errors during logout.
    // The FCMTokenService already handles these gracefully via an INFO log.
    final isFcmEndpoint = err.requestOptions.path.contains('fcm-tokens');
    final isExpectedAuthError =
        err.response?.statusCode == 401 || err.response?.statusCode == 404;

    if (kLogsOn && !(isFcmEndpoint && isExpectedAuthError)) {
      debugPrint(
          '❌ [API] ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      debugPrint('Message: ${err.message}');
    }

    return super.onError(err, handler);
  }
}
