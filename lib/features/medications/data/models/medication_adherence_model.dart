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
}

/// One day of adherence as the server sends it.
class AdherenceDayModel extends AdherenceDay {
  const AdherenceDayModel({
    super.id,
    required super.taken,
    required super.takenAt,
    super.takenDoses,
    super.scheduledDoses,
  });

  factory AdherenceDayModel.fromJson(Map<String, dynamic> json) {
    final dateStr = json['dateTaken'] ?? json['date'] ?? json['takenAt'];
    return AdherenceDayModel(
      id: json['id'],
      taken: takenFromJson(json),
      takenAt:
          dateStr != null ? DateTime.parse(dateStr).toLocal() : clock.now(),
      takenDoses: json['takenDoses'] as int?,
      scheduledDoses: json['scheduledDoses'] as int?,
    );
  }
}

/// The server's `taken` for a day: null while a dose can still be confirmed.
/// Older responses sent a `status` instead.
bool? takenFromJson(Map<String, dynamic> json) => switch (json['taken']) {
      final bool taken => taken,
      _ when json['status'] == 'taken' || json['status'] == 'completed' => true,
      _ when json.containsKey('taken') => null,
      _ => false,
    };
