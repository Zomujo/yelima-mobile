import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/api/interceptors/auth_interceptor.dart';
import 'package:yelima/core/managers/token_manager.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';

class MockTokenManager extends Mock implements TokenManager {}
class MockSessionLifecycleService extends Mock implements SessionLifecycleService {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}
class MockDio extends Mock implements Dio {}

void main() {
  late AuthInterceptor interceptor;
  late MockTokenManager mockTokenManager;

  setUp(() {
    mockTokenManager = MockTokenManager();
    
    interceptor = AuthInterceptor(
      tokenManager: mockTokenManager,
    );
    
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('AuthInterceptor', () {
    test('onRequest adds Bearer token when token is available', () async {
      when(() => mockTokenManager.getValidAuthToken()).thenAnswer((_) async => 'fake_token');
      
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await Future.delayed(Duration.zero);

      verify(() => handler.next(any(that: isA<RequestOptions>()
          .having((o) => o.headers['Authorization'], 'Authorization', 'Bearer fake_token')))).called(1);
    });

    test('onRequest does not add token when getValidAuthToken returns null', () async {
      when(() => mockTokenManager.getValidAuthToken()).thenAnswer((_) async => null);

      final options = RequestOptions(path: '/auth/login');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await Future.delayed(Duration.zero);

      verify(() => handler.next(any(that: isA<RequestOptions>()
          .having((o) => o.headers.containsKey('Authorization'), 'hasAuth', false)))).called(1);
      
      verify(() => mockTokenManager.getValidAuthToken()).called(1);
    });
  });
}
