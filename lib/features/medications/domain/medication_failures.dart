import '../../../core/failures/app_failure.dart';

/// A dose can't be confirmed before its time.
final class DoseNotDueFailure extends FeatureFailure {
  const DoseNotDueFailure();
}

/// A medication needs a name and a dosage.
final class MissingNameOrDosageFailure extends FeatureFailure {
  const MissingNameOrDosageFailure();
}

/// A medication needs at least one dose time.
final class MissingScheduleFailure extends FeatureFailure {
  const MissingScheduleFailure();
}

/// A medication with the same name and dosage already exists.
final class DuplicateMedicationFailure extends FeatureFailure {
  const DuplicateMedicationFailure();
}
