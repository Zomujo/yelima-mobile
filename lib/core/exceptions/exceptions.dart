import 'package:dio/dio.dart';

/// An HTTP error from the API; [code] is the status code as text.
class ApiException implements Exception {
  const ApiException(this.message, {this.code});

  /// The response's message, or a fallback; [code] is null when there was no response.
  factory ApiException.fromDioError(DioException e) {
    final data = e.response?.data;
    final message = data is Map
        ? data['message'] ?? data['error'] ?? data['errors']?.toString()
        : null;
    return ApiException(
        (message ?? e.message ?? 'An unexpected error occurred').toString(),
        code: e.response?.statusCode?.toString());
  }

  final String? message;
  final String? code;

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
