import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension MonthNames on AppLocalizations {
  /// "12th July 2026", with the month in the app's language.
  String longDate(DateTime date) {
    final d = date.day;
    final suffix = d >= 11 && d <= 13
        ? 'th'
        : switch (d % 10) { 1 => 'st', 2 => 'nd', 3 => 'rd', _ => 'th' };
    return '$d$suffix ${monthNames[date.month - 1]} ${date.year}';
  }

  /// "Today", "Yesterday", or the [longDate].
  String dayLabel(DateTime date) {
    final now = clock.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    return switch (days) { 0 => today, 1 => yesterday, _ => longDate(date) };
  }

  /// The name of a supported language, by its code.
  String languageName(String code) => switch (code) {
        'tw' => akanTwi,
        'ee' => ewe,
        'ga' => ga,
        _ => english,
      };

  /// Full month names, January first.
  List<String> get monthNames => [
        monthJanuary,
        monthFebruary,
        monthMarch,
        monthApril,
        monthMay,
        monthJune,
        monthJuly,
        monthAugust,
        monthSeptember,
        monthOctober,
        monthNovember,
        monthDecember,
      ];
}
