import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import '../exceptions/exceptions.dart';

typedef JSON = Map<String, dynamic>;

extension ResponseData on Response {
  JSON? get value => data is Map ? data['data'] : null;
  String? get message => data is Map ? data['message'] : "Unknown error";
}

extension DioExceptionExtension on DioException {
  String? get responseMessage =>
      response?.data is Map ? response?.data['message'] : message;
}

class APIClient {
  late final Dio _dio;

  APIClient({required String baseUrl}) {
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
      AuthInterceptor(dio: _dio),
      ErrorInterceptor(),
    ]);
  }

  Future<dynamic> get(String path, {JSON? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> post(String path,
      {dynamic data, JSON? queryParameters}) async {
    try {
      final response =
          await _dio.post(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> postMultipart(String path,
      {JSON? fields, Map<String, MultipartFile>? files, JSON? queryParameters}) async {
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

  Future<dynamic> put(String path, {dynamic data, JSON? queryParameters}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  void _handleDioError(DioException e) {
    debugPrint('API Error: ${e.responseMessage}');
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw const NetworkException('No internet connection. Please check your network and try again.');
    }
    // Map to custom ApiException
    throw ApiException.fromDioError(e);
  }

  void dispose() => _dio.close();
}
