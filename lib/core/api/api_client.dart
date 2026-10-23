import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/session_expiry.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import '../exceptions/exceptions.dart';

typedef JSON = Map<String, dynamic>;

/// The `data` and `message` of an API response.
extension ResponseData on Response {
  JSON? get value => data is Map ? data['data'] : null;
  String? get message => data is Map ? data['message'] : "Unknown error";
}


/// The HTTP client for the backend, with auth and logging interceptors.
class APIClient {
  /// Lets the server replay, not repeat, a write sent again with the same [key] within 48 h.
  static Options idempotent(String key) =>
      Options(headers: {'Idempotency-Key': key});

  late final Dio _dio;

  APIClient({required String baseUrl, SessionExpiry? sessionExpiry}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(dio: _dio, sessionExpiry: sessionExpiry),
    ]);
  }

  /// Wraps a ready-made Dio without the auth interceptors, e.g. one backed by a fake API in tests.
  APIClient.withDio(Dio dio) : _dio = dio;

  Future<dynamic> get(String path,
      {JSON? queryParameters, Options? options}) async {
    try {
      final response = await _dio.get(path,
          queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> post(String path,
      {dynamic data, JSON? queryParameters, Options? options}) async {
    try {
      final response = await _dio.post(path,
          data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> postMultipart(String path,
      {JSON? fields,
      Map<String, MultipartFile>? files,
      JSON? queryParameters}) async {
    try {
      final formData = FormData();
      if (files != null) {
        files.forEach((key, value) => formData.files.add(MapEntry(key, value)));
      }
      if (fields != null) {
        formData.fields.addAll(
            fields.entries.map((e) => MapEntry(e.key, e.value.toString())));
      }

      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> put(String path,
      {dynamic data, JSON? queryParameters, Options? options}) async {
    try {
      final response = await _dio.put(path,
          data: data, queryParameters: queryParameters, options: options);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> patch(String path, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.patch(path, data: data, options: options);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> delete(String path, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.delete(path, data: data, options: options);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  void _handleDioError(DioException e) {
    debugPrint('API Raw Data: ${e.response?.data}');
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw const NetworkException(
          'No internet connection. Please check your network and try again.');
    }
    throw ApiException.fromDioError(e);
  }

  void dispose() => _dio.close();
}
