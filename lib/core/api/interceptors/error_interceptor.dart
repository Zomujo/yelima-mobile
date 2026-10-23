import 'package:dio/dio.dart';

/// Carries the backend's error message on the DioException. Sign-in state is
/// left to [AuthInterceptor], so a 401 never signs anyone out from here.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(
      DioException(
        message: err.response?.data is Map
            ? err.response?.data['message']
            : err.message,
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
      ),
    );
  }
}
