import '../../domain/entities/medication_adherence.dart';
import 'package:clock/clock.dart';

/// Weekly adherence as the server sends it.
class MedicationAdherenceModel extends MedicationAdherence {
  const MedicationAdherenceModel({
    required super.rate,
    required super.days,
  });

  factory MedicationAdherenceModel.fromJson(Map<String, dynamic> json) {
    var daysList = <AdherenceDayModel>[];
    if (json['days'] != null) {
      json['days'].forEach((v) {
        daysList.add(AdherenceDayModel.fromJson(v));
      });
    }
    return MedicationAdherenceModel(
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      days: daysList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'days': days
          .map((e) => {
                'id': e.id,
                'taken': e.taken,
                'takenAt': e.takenAt.toIso8601String(),
              })
          .toList(),
    };
  }
}

/// One day of adherence as the server sends it.
class AdherenceDayModel extends AdherenceDay {
  const AdherenceDayModel({
    super.id,
    required super.taken,
    required super.takenAt,
  });

  factory AdherenceDayModel.fromJson(Map<String, dynamic> json) {
    final dateStr = json['dateTaken'] ?? json['date'] ?? json['takenAt'];
    final bool isTaken = json['taken'] == true ||
        json['status'] == 'taken' ||
        json['status'] == 'completed';
    return AdherenceDayModel(
      id: json['id'],
      taken: isTaken,
      takenAt:
          dateStr != null ? DateTime.parse(dateStr).toLocal() : clock.now(),
    );
  }
}
