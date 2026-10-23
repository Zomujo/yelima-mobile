import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/shared/utils/failure_message.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('cancelling shows nothing', () {
    expect(const CancelledFailure().message(l10n), isNull);
  });

  test('each failure has its own words', () {
    expect(const NetworkFailure().message(l10n), l10n.failureOffline);
    expect(
        const ServerFailure(status: 400).message(l10n), l10n.failureRejected);
    expect(const ServerFailure(status: 500).message(l10n), l10n.failureServer);
    expect(const AuthFailure(AuthError.emailInUse).message(l10n),
        l10n.authErrorEmailInUse);
  });

  test('the server\'s own text never reaches the user', () {
    expect(
        const ServerFailure(status: 500, detail: 'TypeError at line 3')
            .message(l10n),
        isNot(contains('TypeError')));
  });

  test('a bug shows a generic message, not the exception', () {
    expect(UnexpectedFailure(StateError('null check')).message(l10n),
        l10n.failureUnexpected);
  });
}
