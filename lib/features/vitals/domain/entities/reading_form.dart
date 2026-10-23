import '../reading_limits.dart';
import '../vital_severity_thresholds.dart';
import 'vital_history_entity.dart';

/// Which kind of reading is being logged.
enum VitalKind { bloodPressure, bloodSugar }

/// A reading as entered in the log form.
class ReadingForm {
  const ReadingForm({
    required this.kind,
    this.subType = 'fasting',
    required this.systolic,
    required this.diastolic,
    required this.sugarLevel,
    required this.recordedAt,
  });

  final VitalKind kind;

  /// For blood sugar: fasting, random and so on.
  final String subType;
  final int systolic;
  final int diastolic;
  final double sugarLevel;
  final DateTime recordedAt;

  /// Why the reading can't be saved, or null.
  ReadingError? get problem => kind == VitalKind.bloodPressure
      ? ReadingLimits.bloodPressureError(systolic, diastolic)
      : ReadingLimits.bloodSugarError(sugarLevel);

  /// The reading to save, graded with the backend's table.
  VitalHistoryEntity toReading(String id) => kind == VitalKind.bloodPressure
      ? VitalHistoryEntity(
          id: id,
          vitalType: 'bloodPressure',
          vitalName: 'Blood Pressure',
          value: '$systolic/$diastolic',
          unit: 'mmHg',
          severity: VitalSeverityThresholds.bloodPressure(systolic, diastolic),
          recordedAt: recordedAt,
        )
      : VitalHistoryEntity(
          id: id,
          vitalType: 'bloodSugar',
          vitalName: 'Blood Sugar',
          vitalSubType: subType,
          value: sugarLevel.toStringAsFixed(1),
          unit: 'mmol/L',
          severity: VitalSeverityThresholds.bloodSugar(sugarLevel),
          recordedAt: recordedAt,
        );
}
