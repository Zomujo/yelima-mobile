import '../../domain/entities/medication_entity.dart';
import 'package:clock/clock.dart';

/// A medication in today's list as the server sends it.
class MedicationModel extends MedicationEntity {
  final Map<String, dynamic>? morning;
  final Map<String, dynamic>? afternoon;
  final Map<String, dynamic>? evening;

  /// Whether the server sent `toBeTakenAt`; if not, [toBeTakenAt] is only a placeholder.
  final bool hasServerTime;

  const MedicationModel({
    required super.id,
    required super.name,
    required super.dosage,
    required super.purpose,
    required super.toBeTakenAt,
    required super.taken,
    this.morning,
    this.afternoon,
    this.evening,
    this.hasServerTime = true,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      purpose: json['purpose'] ?? '',
      toBeTakenAt: json['toBeTakenAt'] != null
          ? DateTime.parse(json['toBeTakenAt']).toLocal()
          : clock.now(),
      taken: json['taken'] ?? false,
      morning: json['morning'],
      afternoon: json['afternoon'],
      evening: json['evening'],
      hasServerTime: json['toBeTakenAt'] != null,
    );
  }
}
