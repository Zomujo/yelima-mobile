import '../../../core/failures/app_failure.dart';

/// Why a reading can't be saved.
enum ReadingError { bpOutOfRange, systolicNotAboveDiastolic, sugarOutOfRange }

/// A reading outside what the app accepts.
final class ReadingFailure extends FeatureFailure {
  const ReadingFailure(this.error);

  final ReadingError error;

  @override
  List<Object?> get props => [error];
}

/// The ranges a reading can be entered in, shared by the pickers, the save check and the prefill.
abstract final class ReadingLimits {
  static const systolicMin = 60, systolicMax = 250;
  static const diastolicMin = 40, diastolicMax = 150;
  static const sugarMin = 1.0, sugarMax = 33.3; // mmol/L

  /// Null when the blood pressure can be saved, otherwise why not.
  static ReadingError? bloodPressureError(int systolic, int diastolic) {
    if (systolic < systolicMin ||
        systolic > systolicMax ||
        diastolic < diastolicMin ||
        diastolic > diastolicMax) {
      return ReadingError.bpOutOfRange;
    }
    if (systolic <= diastolic) return ReadingError.systolicNotAboveDiastolic;
    return null;
  }

  /// Null when the blood sugar (mmol/L) can be saved, otherwise why not.
  static ReadingError? bloodSugarError(double mmolPerLitre) =>
      mmolPerLitre < sugarMin || mmolPerLitre > sugarMax
          ? ReadingError.sugarOutOfRange
          : null;
}
