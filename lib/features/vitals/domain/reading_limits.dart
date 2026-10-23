/// Why a reading can't be saved.
enum ReadingError {
  bpOutOfRange,
  systolicNotAboveDiastolic,
  sugarOutOfRange;

  /// The English explanation, used where no translations are available.
  String get message => switch (this) {
        bpOutOfRange =>
          'Blood pressure must be between ${ReadingLimits.systolicMin}/${ReadingLimits.diastolicMin} and ${ReadingLimits.systolicMax}/${ReadingLimits.diastolicMax}.',
        systolicNotAboveDiastolic =>
          'The top number (systolic) must be higher than the bottom number (diastolic).',
        sugarOutOfRange =>
          'Blood sugar must be between ${ReadingLimits.sugarMin} and ${ReadingLimits.sugarMax} mmol/L.',
      };
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
