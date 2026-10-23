import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:yelima/core/exceptions/exceptions.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/failures/guard.dart';

final class DoseNotDue extends FeatureFailure {
  const DoseNotDue();
}

void main() {
  DioException dio(DioExceptionType type, [int? status]) => DioException(
        requestOptions: RequestOptions(),
        type: type,
        response: status == null
            ? null
            : Response(requestOptions: RequestOptions(), statusCode: status),
      );

  group('AppFailure.from', () {
    final cases = <String, (Object, AppFailure)>{
      'offline': (const NetworkException(), const NetworkFailure()),
      'timeout': (TimeoutException('slow'), const NetworkFailure()),
      'socket': (const SocketException('down'), const NetworkFailure()),
      'dio timeout': (
        dio(DioExceptionType.receiveTimeout),
        const NetworkFailure()
      ),
      'dio no connection': (
        dio(DioExceptionType.connectionError),
        const NetworkFailure()
      ),
      'dio 401': (
        dio(DioExceptionType.badResponse, 401),
        const UnauthorizedFailure()
      ),
      'dio 404': (
        dio(DioExceptionType.badResponse, 404),
        const NotFoundFailure()
      ),
      'api 403': (
        const ApiException('no', code: '403'),
        const UnauthorizedFailure()
      ),
      'api 404': (
        const ApiException('gone', code: '404'),
        const NotFoundFailure()
      ),
      'api 422 keeps the server text for logs': (
        const ApiException('bad phone', code: '422'),
        const ServerFailure(status: 422, detail: 'bad phone')
      ),
      'api 500': (
        const ApiException('boom', code: '500'),
        const ServerFailure(status: 500, detail: 'boom')
      ),
      'user cancelled': (
        const UserCanceledException(),
        const CancelledFailure()
      ),
      'google sheet closed': (
        PlatformException(code: 'sign_in_canceled'),
        const CancelledFailure()
      ),
      'firebase auth code': (
        FirebaseAuthException(code: 'invalid-credential'),
        const AuthFailure(AuthError.wrongPassword)
      ),
      'firebase auth offline': (
        FirebaseAuthException(code: 'network-request-failed'),
        const NetworkFailure()
      ),
      'firestore unavailable': (
        FirebaseException(plugin: 'firestore', code: 'unavailable'),
        const NetworkFailure()
      ),
      'database error': (
        SqliteException(1, 'disk I/O'),
        const StorageFailure()
      ),
    };

    cases.forEach((name, c) {
      test(name, () => expect(AppFailure.from(c.$1), c.$2));
    });

    test('a failure thrown on purpose passes through as is', () {
      expect(AppFailure.from(const DoseNotDue()), const DoseNotDue());
    });

    test('anything else is unexpected and keeps the error', () {
      final error = StateError('bug');
      expect(AppFailure.from(error), UnexpectedFailure(error));
    });
  });

  test('only 4xx server failures count as rejected', () {
    expect(const ServerFailure(status: 409).isRejected, isTrue);
    expect(const ServerFailure(status: 503).isRejected, isFalse);
    expect(const ServerFailure().isRejected, isFalse);
  });

  group('guard', () {
    late List<Object> reported;

    setUp(() {
      reported = [];
      reportUnexpectedFailure = (e, _) => reported.add(e);
    });
    tearDown(() => reportUnexpectedFailure = (_, __) {});

    test('returns the value on success', () async {
      expect(await guard(() async => 42), right<AppFailure, int>(42));
    });

    test('returns the failure instead of throwing', () async {
      expect(await guard<int>(() => throw const NetworkException()),
          left<AppFailure, int>(const NetworkFailure()));
      expect(reported, isEmpty, reason: 'planned failures are not bugs');
    });

    test('reports unexpected errors to Crashlytics', () async {
      final error = StateError('bug');
      await guard<void>(() => throw error);
      expect(reported, [error]);
    });
  });
}
