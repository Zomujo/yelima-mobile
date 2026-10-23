import 'dart:ui' show PlatformDispatcher;

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// `context.l10n` for the current translations.
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// The language codes the app is translated into.
final languageCodes = [
  for (final l in AppLocalizations.supportedLocales) l.languageCode
];

/// Translations for [locale], or for the phone's language when none was picked.
AppLocalizations l10nFor(Locale? locale) {
  final code = (locale ?? PlatformDispatcher.instance.locale).languageCode;
  return lookupAppLocalizations(
      Locale(languageCodes.contains(code) ? code : 'en'));
}

/// Translated words built from app data: months, dates, languages, gender, conditions.
extension MonthNames on AppLocalizations {
  /// "12th July 2026", with the month in the app's language.
  String longDate(DateTime date) {
    final d = date.day;
    final suffix = d >= 11 && d <= 13
        ? 'th'
        : switch (d % 10) { 1 => 'st', 2 => 'nd', 3 => 'rd', _ => 'th' };
    return '$d$suffix ${monthNames[date.month - 1]} ${date.year}';
  }

  /// The stored gender (`Male`, `Female`, `Other`) in the app's language.
  String genderName(String? gender) => switch (gender?.toLowerCase()) {
        'male' => male,
        'female' => female,
        'other' => otherGender,
        null || '' => notAvailable,
        _ => gender!,
      };

  /// A stored condition name in the app's language.
  String conditionName(String condition) => switch (condition.toLowerCase()) {
        'hypertension' => hypertension,
        'diabetes' => diabetes,
        _ => condition.isEmpty
            ? condition
            : condition[0].toUpperCase() + condition.substring(1),
      };

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
