import '../../domain/entities/medication_history_entity.dart';
import 'package:clock/clock.dart';

import 'medication_adherence_model.dart' show takenFromJson;

/// A medication's monthly history as the server sends it.
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

/// One day of a medication's history as the server sends it.
class MedicationLogModel extends MedicationLogEntity {
  const MedicationLogModel({
    required super.id,
    required super.taken,
    required super.takenAt,
  });

  factory MedicationLogModel.fromJson(Map<String, dynamic> json) {
    final dateStr = json['dateTaken'] ?? json['date'] ?? json['takenAt'];
    return MedicationLogModel(
      id: json['id'] ?? '',
      taken: takenFromJson(json),
      takenAt:
          dateStr != null ? DateTime.parse(dateStr).toLocal() : clock.now(),
    );
  }
}
