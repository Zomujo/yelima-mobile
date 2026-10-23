import 'package:equatable/equatable.dart';

/// One saved blood pressure or blood sugar reading.
class VitalHistoryEntity extends Equatable {
  const VitalHistoryEntity({
    required this.id,
    required this.vitalType,
    required this.value,
    required this.unit,
    required this.severity,
    required this.vitalName,
    this.vitalSubType,
    this.recordedAt,
  });

  final String id;
  final String vitalType;
  final String value;
  final String unit;
  final String severity;
  final String vitalName;
  final String? vitalSubType;
  final DateTime? recordedAt;

  bool get isBloodPressure =>
      vitalType.toLowerCase() == 'bloodpressure' ||
      vitalName.toLowerCase() == 'blood pressure';

  /// Older rows call it blood glucose.
  bool get isBloodSugar =>
      const {'bloodsugar', 'bloodglucose'}.contains(vitalType.toLowerCase()) ||
      const {'blood sugar', 'blood glucose'}.contains(vitalName.toLowerCase());

  VitalSeverity get grade => VitalSeverityExt.fromString(severity);

  @override
  List<Object?> get props => [
        id,
        vitalType,
        value,
        unit,
        severity,
        vitalName,
        vitalSubType,
        recordedAt
      ];
}

/// How a reading is graded, from the backend's table.
enum VitalSeverity {
  normal,
  slightlyHigh,
  high,
  veryHigh,
  critical,
  low,
  criticallyLow,
  unknown
}

extension VitalSeverityExt on VitalSeverity {
  /// Maps a stored grade to a display level. Covers the server's labels (see
  /// `VitalSeverityThresholds`) and older app labels still in local data.
  static VitalSeverity fromString(String? val) => switch (val?.toLowerCase()) {
        'normal' || 'good' || 'in_target' => VitalSeverity.normal,
        'elevated' || 'slightly_high' => VitalSeverity.slightlyHigh,
        'high' || 'hypertensive' => VitalSeverity.high,
        'very_high' => VitalSeverity.veryHigh,
        'critical' ||
        'crisis' ||
        'hypertensive_crisis' ||
        'critically_high' =>
          VitalSeverity.critical,
        'low' || 'hypotensive' => VitalSeverity.low,
        'critically_low' || 'severe_hypotension' => VitalSeverity.criticallyLow,
        _ => VitalSeverity.unknown,
      };
}

/// The newest blood pressure and blood sugar readings.
class LatestVitals extends Equatable {
  const LatestVitals({this.bloodPressure, this.bloodSugar});

  final VitalHistoryEntity? bloodPressure;
  final VitalHistoryEntity? bloodSugar;

  /// The newest of each kind in [readings].
  factory LatestVitals.from(List<VitalHistoryEntity> readings) {
    final newest = _newestFirst(readings);
    return LatestVitals(
      bloodPressure: newest.where((r) => r.isBloodPressure).firstOrNull,
      bloodSugar: newest.where((r) => r.isBloodSugar).firstOrNull,
    );
  }

  /// The blood pressure as (systolic, diastolic), or null.
  (int, int)? get systolicDiastolic {
    final parts = bloodPressure?.value.split('/');
    if (parts == null || parts.length != 2) return null;
    final sys = int.tryParse(parts[0].trim());
    final dia = int.tryParse(parts[1].trim());
    return sys == null || dia == null ? null : (sys, dia);
  }

  /// The blood sugar in mmol/L, or null.
  double? get sugarLevel => double.tryParse(bloodSugar?.value.trim() ?? '');

  /// Newest first. Undated rows (server rows, already newest first) keep their order, after dated ones.
  static List<VitalHistoryEntity> _newestFirst(List<VitalHistoryEntity> rows) {
    final indexed = rows.indexed.toList()
      ..sort((a, b) {
        final (ta, tb) = (a.$2.recordedAt, b.$2.recordedAt);
        if (ta != null && tb != null && ta != tb) return tb.compareTo(ta);
        if ((ta == null) != (tb == null)) return ta == null ? 1 : -1;
        return a.$1.compareTo(b.$1);
      });
    return [for (final (_, v) in indexed) v];
  }

  @override
  List<Object?> get props => [bloodPressure, bloodSugar];
}
