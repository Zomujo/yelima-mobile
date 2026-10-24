import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/utils/validators.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('new passwords need 6 characters', () {
    expect(Validators.isValidNewPassword('12345'), isFalse);
    expect(Validators.isValidNewPassword('123456'), isTrue);
    expect(Validators.newPassword('short', l10n), l10n.passwordHint);
  });

  test('accepts long domains and plus addresses, rejects broken emails', () {
    expect(Validators.isValidEmail('ama+care@clinic.health'), isTrue);
    expect(Validators.isValidEmail('ama@clinic'), isFalse);
    expect(Validators.email('ama@', l10n), l10n.authErrorInvalidEmail);
  });

  test('empty fields show no error until typed in', () {
    expect(Validators.email('', l10n), isNull);
    expect(Validators.newPassword(null, l10n), isNull);
  });
}
