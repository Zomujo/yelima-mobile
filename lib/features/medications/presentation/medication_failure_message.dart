import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/failures/app_failure.dart';
import '../../../shared/utils/failure_message.dart';
import '../domain/medication_failures.dart';

/// Words for medication failures, falling back to the shared ones.
extension MedicationFailureMessage on AppFailure {
  String? medicationMessage(AppLocalizations l10n) => switch (this) {
        DoseNotDueFailure() => l10n.doseNotDue,
        MissingNameOrDosageFailure() => l10n.medicationNameDosageRequired,
        MissingScheduleFailure() => l10n.medicationScheduleRequired,
        DuplicateMedicationFailure() => l10n.medicationDuplicate,
        _ => message(l10n),
      };
}
