import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/failures/app_failure.dart';
import '../../../shared/utils/failure_message.dart';
import '../domain/reading_limits.dart';

/// Words for reading failures, falling back to the shared ones.
extension VitalFailureMessage on AppFailure {
  String? vitalMessage(AppLocalizations l10n) => switch (this) {
        ReadingFailure(error: ReadingError.bpOutOfRange) =>
          l10n.readingErrorBpRange(
              ReadingLimits.systolicMin,
              ReadingLimits.diastolicMin,
              ReadingLimits.systolicMax,
              ReadingLimits.diastolicMax),
        ReadingFailure(error: ReadingError.systolicNotAboveDiastolic) =>
          l10n.readingErrorSystolicNotAbove,
        ReadingFailure(error: ReadingError.sugarOutOfRange) =>
          l10n.readingErrorSugarRange(
              '${ReadingLimits.sugarMin}', '${ReadingLimits.sugarMax}'),
        _ => message(l10n),
      };
}
