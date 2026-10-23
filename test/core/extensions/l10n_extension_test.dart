import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final fixed = Clock.fixed(DateTime(2026, 10, 23, 9, 30));

  test('labels today and yesterday', () {
    withClock(fixed, () {
      expect(l10n.dayLabel(DateTime(2026, 10, 23, 23, 59)), 'Today');
      expect(l10n.dayLabel(DateTime(2026, 10, 22)), 'Yesterday');
    });
  });

  test('uses the ordinal day for older dates, including 11th-13th', () {
    withClock(fixed, () {
      expect(l10n.dayLabel(DateTime(2026, 7, 1)), '1st July 2026');
      expect(l10n.dayLabel(DateTime(2026, 7, 12)), '12th July 2026');
      expect(l10n.dayLabel(DateTime(2026, 7, 23)), '23rd July 2026');
    });
  });

  test('just after midnight, the previous evening is yesterday', () {
    withClock(Clock.fixed(DateTime(2026, 10, 23, 0, 1)), () {
      expect(l10n.dayLabel(DateTime(2026, 10, 22, 23, 59)), 'Yesterday');
    });
  });

  test('month names follow the language', () {
    final twi = lookupAppLocalizations(const Locale('tw'));
    expect(twi.longDate(DateTime(2026, 7, 1)), '1st ${twi.monthJuly} 2026');
  });
}
