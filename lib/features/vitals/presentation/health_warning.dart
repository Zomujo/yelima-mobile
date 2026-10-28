import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../domain/entities/reading_form.dart';
import '../domain/entities/vital_history_entity.dart';

/// Advice for a dangerous reading; [isCritical] means seek help now.
typedef HealthWarning = ({String title, String message, bool isCritical});

/// The advice for a [kind] reading graded [grade], or null when no action is needed.
HealthWarning? healthWarning(
        VitalKind kind, VitalSeverity grade, AppLocalizations l10n) =>
    switch ((kind, grade)) {
      (VitalKind.bloodPressure, VitalSeverity.critical) => (
          title: l10n.criticalBloodPressureTitle,
          message: l10n.criticalBloodPressureMessage,
          isCritical: true,
        ),
      (VitalKind.bloodPressure, VitalSeverity.veryHigh) => (
          title: l10n.veryHighBloodPressureTitle,
          message: l10n.veryHighBloodPressureMessage,
          isCritical: false,
        ),
      (VitalKind.bloodSugar, VitalSeverity.critical) => (
          title: l10n.criticalBloodSugarTitle,
          message: l10n.criticalBloodSugarMessage,
          isCritical: true,
        ),
      (VitalKind.bloodSugar, VitalSeverity.veryHigh) => (
          title: l10n.veryHighBloodSugarTitle,
          message: l10n.veryHighBloodSugarMessage,
          isCritical: false,
        ),
      (VitalKind.bloodSugar, VitalSeverity.criticallyLow) => (
          title: l10n.criticallyLowBloodSugarTitle,
          message: l10n.criticallyLowBloodSugarMessage,
          isCritical: true,
        ),
      (VitalKind.bloodSugar, VitalSeverity.low) => (
          title: l10n.lowBloodSugarTitle,
          message: l10n.lowBloodSugarMessage,
          isCritical: false,
        ),
      _ => null,
    };
