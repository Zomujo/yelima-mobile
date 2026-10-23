import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:yelima/core/api/api_client.dart';

/// A canned reply from the fake backend.
class FakeReply {
  final int status;
  final Object? body;
  final bool offline;

  const FakeReply(this.status, [this.body]) : offline = false;

  /// Simulates no connection, which the real client maps to NetworkException.
  const FakeReply.offline()
      : status = 0,
        body = null,
        offline = true;

  /// The server's `{data, statusCode, message}` success envelope.
  factory FakeReply.ok(Object? data, {int status = 200}) =>
      FakeReply(status, {'data': data, 'statusCode': status, 'message': 'ok'});

  /// The server's error envelope.
  factory FakeReply.error(int status, [String message = 'error']) =>
      FakeReply(status, {'statusCode': status, 'message': message});
}

/// Fake backend for tests: routes `METHOD path` to canned replies and records every request.
class FakeApi implements HttpClientAdapter {
  final _routes = <String, FakeReply Function(RequestOptions)>{};

  /// Every request the app sent, in order.
  final requests = <RequestOptions>[];

  /// Real [APIClient] whose HTTP layer is this fake.
  late final APIClient client = APIClient.withDio(
    Dio(BaseOptions(baseUrl: 'https://fake.test/'))..httpClientAdapter = this,
  );

  /// Replies to `method path` (path without host or query) with [reply].
  void on(String method, String path, FakeReply reply) =>
      _routes[_key(method, path)] = (_) => reply;

  /// Replies to `method path` with whatever [handler] returns for the request.
  void onRequest(String method, String path,
          FakeReply Function(RequestOptions) handler) =>
      _routes[_key(method, path)] = handler;

  /// Requests sent to `method path`.
  List<RequestOptions> sent(String method, String path) => requests
      .where((r) => _key(r.method, r.uri.path) == _key(method, path))
      .toList();

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final handler = _routes[_key(options.method, options.uri.path)];
    final reply = handler?.call(options) ??
        FakeReply.error(
            404, 'No fake for ${options.method} ${options.uri.path}');
    if (reply.offline) {
      throw DioException.connectionError(
          requestOptions: options, reason: 'FakeApi offline');
    }
    return ResponseBody.fromString(jsonEncode(reply.body), reply.status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        });
  }

  @override
  void close({bool force = false}) {}

  static String _key(String method, String path) =>
      '${method.toUpperCase()} ${path.replaceFirst(RegExp('^/'), '')}';
}
