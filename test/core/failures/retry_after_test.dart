import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/exceptions/exceptions.dart';
import 'package:yelima/core/failures/app_failure.dart';

void main() {
  test('Retry-After in seconds is read; other forms are ignored', () {
    expect(ApiException.parseRetryAfter('30'), const Duration(seconds: 30));
    expect(
        ApiException.parseRetryAfter('Wed, 21 Oct 2026 07:28:00 GMT'), isNull);
    expect(ApiException.parseRetryAfter(null), isNull);
  });

  test('a 429 is a rate limit to wait out, not a rejection', () {
    final failure = AppFailure.from(const ApiException('slow down',
        code: '429', retryAfter: Duration(seconds: 30))) as ServerFailure;

    expect((failure.isRateLimited, failure.isRejected, failure.retryAfter),
        (true, false, const Duration(seconds: 30)));
  });
}
