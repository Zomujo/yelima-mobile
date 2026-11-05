import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/api/interceptors/reachability_interceptor.dart';
import 'package:yelima/core/services/connectivity_service.dart';

class _Connectivity extends Mock implements ConnectivityService {}

/// Answers every request with [reply], or fails with [fail].
class _Server implements HttpClientAdapter {
  ResponseBody? reply;
  DioExceptionType? fail;

  @override
  Future<ResponseBody> fetch(RequestOptions options, _, __) async {
    if (fail case final type?) {
      throw DioException(requestOptions: options, type: type);
    }
    return reply!;
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _body(int status, String type) => ResponseBody.fromString(
        type.contains('json') ? '{}' : '<html></html>', status,
        headers: {
          Headers.contentTypeHeader: [type]
        });

void main() {
  late _Connectivity connectivity;
  late _Server server;
  late Dio dio;

  setUp(() {
    connectivity = _Connectivity();
    server = _Server();
    dio = Dio()
      ..httpClientAdapter = server
      ..interceptors.add(ReachabilityInterceptor(connectivity));
  });

  Future<void> send() =>
      dio.get('https://api.test/x').then((_) {}, onError: (_) {});

  test('any reply from our server, even an error, proves we are online',
      () async {
    server.reply = _body(200, 'application/json; charset=utf-8');
    await send();
    server.reply = _body(500, 'application/json');
    await send();
    verify(() => connectivity.sawReply()).called(2);
  });

  test("a Wi-Fi login page doesn't count as our server", () async {
    server.reply = _body(200, 'text/html');
    await send();
    verifyNever(() => connectivity.sawReply());
  });

  test('a failed connection asks for a fresh check', () async {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      server.fail = type;
      await send();
    }
    verify(() => connectivity.sawNetworkError()).called(3);
    verifyNever(() => connectivity.sawReply());
  });
}
