import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/api/interceptors/logging_interceptor.dart';

void main() {
  test('secrets are hidden in logs, at any depth; the rest is kept', () {
    final logged = LoggingInterceptor.redact({
      'Authorization': 'Bearer abc',
      'fcmToken': 'cRlj...',
      'name': 'Jackson',
      'data': {
        'password': 'hunter2',
        'items': [
          {'idToken': 'x', 'value': 6.0}
        ],
      },
    });

    expect(logged, {
      'Authorization': '[REDACTED]',
      'fcmToken': '[REDACTED]',
      'name': 'Jackson',
      'data': {
        'password': '[REDACTED]',
        'items': [
          {'idToken': '[REDACTED]', 'value': 6.0}
        ],
      },
    });
  });

  test('bodies that are not maps or lists are logged as they are', () {
    expect(LoggingInterceptor.redact('plain'), 'plain');
    expect(LoggingInterceptor.redact(null), isNull);
  });
}
