import 'package:dio/dio.dart';

import '../../services/connectivity_service.dart';

/// Tells [ConnectivityService] what real requests show, so it notices a lost
/// or returning connection without waiting for its next check.
class ReachabilityInterceptor extends Interceptor {
  ReachabilityInterceptor(this._connectivity);

  final ConnectivityService _connectivity;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _sawReply(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionError ||
            DioExceptionType.connectionTimeout ||
            DioExceptionType.sendTimeout ||
            DioExceptionType.receiveTimeout:
        _connectivity.sawNetworkError();
      default:
        if (err.response case final response?) _sawReply(response);
    }
    handler.next(err);
  }

  // Only our server answers in JSON; a Wi-Fi login page answers in HTML.
  void _sawReply(Response response) {
    final type = response.headers.value(Headers.contentTypeHeader) ?? '';
    if (type.contains('json')) _connectivity.sawReply();
  }
}
