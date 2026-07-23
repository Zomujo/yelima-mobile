import 'package:equatable/equatable.dart';

class VitalHistoryEntity extends Equatable {
  final String id;
  final String vitalType;
  final String value;
  final String unit;
  final String severity;
  final String vitalName;
  final DateTime? recordedAt;

  const VitalHistoryEntity({
    required this.id,
    required this.vitalType,
    required this.value,
    required this.unit,
    required this.severity,
    required this.vitalName,
    this.recordedAt,
  });

  @override
  List<Object?> get props => [id, vitalType, value, unit, severity, vitalName, recordedAt];
}

class HomeMetricsEntity extends Equatable {
  final String? bloodPressure;
  final String? bloodGlucose;
  final double? adherenceRate;

  const HomeMetricsEntity({
    this.bloodPressure,
    this.bloodGlucose,
    this.adherenceRate,
  });

  @override
  List<Object?> get props => [bloodPressure, bloodGlucose, adherenceRate];

  HomeMetricsEntity copyWith({
    String? bloodPressure,
    String? bloodGlucose,
    double? adherenceRate,
  }) {
    return HomeMetricsEntity(
      bloodPressure: bloodPressure ?? this.bloodPressure,
      bloodGlucose: bloodGlucose ?? this.bloodGlucose,
      adherenceRate: adherenceRate ?? this.adherenceRate,
    );
  }

  /// Returns the blood pressure parsed as a tuple of (systolic, diastolic).
  (int, int)? get parsedBloodPressure {
    if (bloodPressure == null || bloodPressure!.isEmpty || bloodPressure!.contains('--')) return null;
    final parts = bloodPressure!.split('/');
    if (parts.length != 2) return null;
    final sys = int.tryParse(parts[0].trim());
    final dia = int.tryParse(parts[1].trim());
    if (sys != null && dia != null) return (sys, dia);
    return null;
  }

  /// Returns the blood glucose parsed as a double.
  double? get parsedBloodGlucose {
    if (bloodGlucose == null || bloodGlucose!.isEmpty || bloodGlucose!.contains('--')) return null;
    return double.tryParse(bloodGlucose!.trim());
  }
}
