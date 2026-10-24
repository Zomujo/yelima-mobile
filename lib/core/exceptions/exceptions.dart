import 'package:dio/dio.dart';

/// An HTTP error from the API; [code] is the status code as text.
class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.retryAfter});

  /// The response's message, or a fallback; [code] is null when there was no response.
  factory ApiException.fromDioError(DioException e) {
    final data = e.response?.data;
    final raw =
        data is Map ? data['message'] ?? data['error'] ?? data['errors'] : null;
    // NestJS validation errors send a list of messages.
    final message = raw is List ? raw.join(', ') : raw;
    return ApiException(
        (message ?? e.message ?? 'An unexpected error occurred').toString(),
        code: e.response?.statusCode?.toString(),
        retryAfter: parseRetryAfter(e.response?.headers.value('retry-after')));
  }

  /// A `Retry-After` header in seconds; the HTTP-date form is ignored.
  static Duration? parseRetryAfter(String? header) {
    final seconds = int.tryParse(header?.trim() ?? '');
    return seconds == null || seconds < 0 ? null : Duration(seconds: seconds);
  }

  final String? message;
  final String? code;

  /// How long the server asked us to wait (on 429).
  final Duration? retryAfter;

  @override
  String toString() => 'ApiException($code): $message';
}

/// No connection, or the request timed out.
class NetworkException implements Exception {
  const NetworkException([this.message]);

  final String? message;

  @override
  String toString() => 'NetworkException: ${message ?? 'no connection'}';
}

/// The user closed a sign-in sheet.
class UserCanceledException implements Exception {
  const UserCanceledException();
}
