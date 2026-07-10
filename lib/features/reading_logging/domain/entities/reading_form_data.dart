/// Framework-agnostic domain entity representing a reading to be saved.
class ReadingFormData {
  /// 0 = Blood Pressure, 1 = Blood Glucose
  final int selectedTypeIndex;
  final int systolic;
  final int diastolic;
  final double sugarLevel;
  final DateTime recordedAt;

  const ReadingFormData({
    required this.selectedTypeIndex,
    required this.systolic,
    required this.diastolic,
    required this.sugarLevel,
    required this.recordedAt,
  });
}
