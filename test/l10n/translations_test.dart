import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  for (final code in ['tw', 'ee', 'ga']) {
    final l10n = lookupAppLocalizations(Locale(code));

    test('$code: plural messages fill in the count', () {
      expect(l10n.changesWaiting(1), isNot(contains('{')));
      expect(l10n.changesWaiting(3), contains('3'));
      expect(l10n.unsyncedBody(2), contains('2'));
    });

    test('$code: newer messages are translated, not English', () {
      expect(l10n.sessionExpiredTitle, isNot(en.sessionExpiredTitle));
      expect(l10n.medicationReminderBody, isNot(en.medicationReminderBody));
      expect(l10n.doseTooLate, isNot(en.doseTooLate));
    });
  }
}
