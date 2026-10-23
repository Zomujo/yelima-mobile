import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/api/interceptors/auth_interceptor.dart';
import 'package:yelima/core/managers/token_manager.dart';
import 'package:yelima/core/services/session_expiry.dart';

class MockTokenManager extends Mock implements TokenManager {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockDio extends Mock implements Dio {}

class MockErrorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late MockFirebaseAuth auth;
  late MockDio dio;
  late SessionExpiry expiry;
  late AuthInterceptor interceptor;
  late MockErrorHandler handler;

  DioException unauthorized({bool isRetry = false}) {
    final options = RequestOptions(path: '/api/v1/client/medications')
      ..extra['isRetry'] = isRetry;
    return DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 401),
      type: DioExceptionType.badResponse,
    );
  }

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(
        DioException(requestOptions: RequestOptions(path: '')));
    registerFallbackValue(Response(requestOptions: RequestOptions(path: '')));
  });

  setUp(() {
    auth = MockFirebaseAuth();
    dio = MockDio();
    expiry = SessionExpiry();
    handler = MockErrorHandler();
    final tokens = MockTokenManager();
    when(() => tokens.clearTokens()).thenAnswer((_) async {});
    when(() => auth.signOut()).thenAnswer((_) async {});
    interceptor = AuthInterceptor(
        tokenManager: tokens,
        dio: dio,
        firebaseAuth: auth,
        sessionExpiry: expiry);
  });

  Future<void> fail(DioException err) async {
    interceptor.onError(err, handler);
    await pumpEventQueue();
  }

  test(
      'CORE-EC-01: a 401 with nobody signed in fails at once instead of hanging',
      () async {
    when(() => auth.currentUser).thenReturn(null);

    await fail(unauthorized());

    verify(() => handler.next(any())).called(1);
  });

  test('a refreshed token retries the request once and returns its result',
      () async {
    final user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken(true)).thenAnswer((_) async => 'fresh');
    when(() => dio.fetch<dynamic>(any())).thenAnswer((i) async => Response(
        requestOptions: i.positionalArguments.first as RequestOptions,
        statusCode: 200));

    await fail(unauthorized());

    verify(() => handler.resolve(any())).called(1);
    expect(expiry.isExpired, isFalse);
  });

  test(
      'CORE-EC-09: a refresh that fails offline keeps the session and signs nobody out',
      () async {
    final user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken(true))
        .thenThrow(FirebaseAuthException(code: 'network-request-failed'));

    await fail(unauthorized());

    verify(() => handler.next(any())).called(1);
    verifyNever(() => auth.signOut());
    expect(expiry.isExpired, isFalse);
  });

  test('a refresh the server refuses locks the app, without wiping anything',
      () async {
    final user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken(true))
        .thenThrow(FirebaseAuthException(code: 'user-token-expired'));

    await fail(unauthorized());

    expect(expiry.isExpired, isTrue);
    verifyNever(() => auth.signOut());
    verify(() => handler.next(any())).called(1);
  });

  test('a second 401 on the retried request locks the app, without signing out',
      () async {
    await fail(unauthorized(isRetry: true));

    expect(expiry.isExpired, isTrue);
    verifyNever(() => auth.signOut());
    verify(() => handler.next(any())).called(1);
  });
}
