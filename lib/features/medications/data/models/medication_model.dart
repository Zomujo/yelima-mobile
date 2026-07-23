import '../../domain/entities/medication_entity.dart';

class MedicationModel extends MedicationEntity {
  final Map<String, dynamic>? morning;
  final Map<String, dynamic>? afternoon;
  final Map<String, dynamic>? evening;

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
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      purpose: json['purpose'] ?? '',
      toBeTakenAt: json['toBeTakenAt'] != null ? DateTime.parse(json['toBeTakenAt']).toLocal() : DateTime.now(),
      taken: json['taken'] ?? false,
      morning: json['morning'],
      afternoon: json['afternoon'],
      evening: json['evening'],
    );
  }
}
