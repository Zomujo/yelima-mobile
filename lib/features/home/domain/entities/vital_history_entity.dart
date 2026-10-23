import 'package:equatable/equatable.dart';

class VitalHistoryEntity extends Equatable {
  final String id;
  final String vitalType;
  final String value;
  final String unit;
  final String severity;
  final String vitalName;
  final String? vitalSubType;
  final DateTime? recordedAt;

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
  static VitalSeverity fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'normal' || 'good' || 'in_target':
        return VitalSeverity.normal;
      case 'elevated' || 'slightly_high':
        return VitalSeverity.slightlyHigh;
      case 'high' || 'hypertensive':
        return VitalSeverity.high;
      case 'very_high':
        return VitalSeverity.veryHigh;
      case 'critical' || 'crisis' || 'hypertensive_crisis' || 'critically_high':
        return VitalSeverity.critical;
      case 'low' || 'hypotensive':
        return VitalSeverity.low;
      case 'critically_low' || 'severe_hypotension':
        return VitalSeverity.criticallyLow;
      default:
        return VitalSeverity.unknown;
    }
  }
}

class HomeMetricsEntity extends Equatable {
  final String? bloodPressure;
  final String? bloodGlucose;
  final double? adherenceRate;
  final String? bpSeverity;
  final String? bgSeverity;

  const HomeMetricsEntity({
    this.bloodPressure,
    this.bloodGlucose,
    this.adherenceRate,
    this.bpSeverity,
    this.bgSeverity,
  });

  @override
  List<Object?> get props =>
      [bloodPressure, bloodGlucose, adherenceRate, bpSeverity, bgSeverity];

  HomeMetricsEntity copyWith({
    String? bloodPressure,
    String? bloodGlucose,
    double? adherenceRate,
    String? bpSeverity,
    String? bgSeverity,
  }) {
    return HomeMetricsEntity(
      bloodPressure: bloodPressure ?? this.bloodPressure,
      bloodGlucose: bloodGlucose ?? this.bloodGlucose,
      adherenceRate: adherenceRate ?? this.adherenceRate,
      bpSeverity: bpSeverity ?? this.bpSeverity,
      bgSeverity: bgSeverity ?? this.bgSeverity,
    );
  }

  /// Returns the blood pressure parsed as a tuple of (systolic, diastolic).
  (int, int)? get parsedBloodPressure {
    if (bloodPressure == null ||
        bloodPressure!.isEmpty ||
        bloodPressure!.contains('--')) {
      return null;
    }
    final parts = bloodPressure!.split('/');
    if (parts.length != 2) return null;
    final sys = int.tryParse(parts[0].trim());
    final dia = int.tryParse(parts[1].trim());
    if (sys != null && dia != null) return (sys, dia);
    return null;
  }

  /// Returns the blood glucose parsed as a double.
  double? get parsedBloodGlucose {
    if (bloodGlucose == null ||
        bloodGlucose!.isEmpty ||
        bloodGlucose!.contains('--')) {
      return null;
    }
    return double.tryParse(bloodGlucose!.trim());
  }

  VitalSeverity get parsedBpSeverity => VitalSeverityExt.fromString(bpSeverity);
  VitalSeverity get parsedBgSeverity => VitalSeverityExt.fromString(bgSeverity);
}
