import 'package:equatable/equatable.dart';

class MedicationHistoryEntity extends Equatable {
  final String medicationName;
  final num adherenceRate;
  final List<MedicationLogEntity> logs;

  const MedicationHistoryEntity({
    required this.medicationName,
    required this.adherenceRate,
    required this.logs,
  });

  @override
  List<Object?> get props => [medicationName, adherenceRate, logs];
}

class MedicationLogEntity extends Equatable {
  final String id;
  final bool taken;
  final DateTime takenAt;

  const MedicationLogEntity({
    required this.id,
    required this.taken,
    required this.takenAt,
  });

  @override
  List<Object?> get props => [id, taken, takenAt];
}
