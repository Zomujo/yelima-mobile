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
}
