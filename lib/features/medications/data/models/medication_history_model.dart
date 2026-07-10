import '../../domain/entities/medication_history_entity.dart';

class MedicationHistoryModel extends MedicationHistoryEntity {
  const MedicationHistoryModel({
    required super.medicationName,
    required super.adherenceRate,
    required super.logs,
  });

  factory MedicationHistoryModel.fromJson(Map<String, dynamic> json) {
    var logsList = <MedicationLogModel>[];
    if (json['logs'] != null) {
      json['logs'].forEach((v) {
        logsList.add(MedicationLogModel.fromJson(v));
      });
    }
    return MedicationHistoryModel(
      medicationName: json['medicationName'] ?? '',
      adherenceRate: json['adherenceRate'] ?? 0,
      logs: logsList,
    );
  }
}

class MedicationLogModel extends MedicationLogEntity {
  const MedicationLogModel({
    required super.id,
    required super.taken,
    required super.takenAt,
  });

  factory MedicationLogModel.fromJson(Map<String, dynamic> json) {
    final dateStr = json['dateTaken'] ?? json['date'] ?? json['takenAt'];
    final bool isTaken = json['taken'] == true || json['status'] == 'taken' || json['status'] == 'completed';
    return MedicationLogModel(
      id: json['id'] ?? '',
      taken: isTaken,
      takenAt: dateStr != null ? DateTime.parse(dateStr).toLocal() : DateTime.now(),
    );
  }
}
