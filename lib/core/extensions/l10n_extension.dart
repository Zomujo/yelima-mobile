import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension MonthNames on AppLocalizations {
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
