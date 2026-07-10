import '../../domain/entities/medication_entity.dart';

class MedicationModel extends MedicationEntity {
  const MedicationModel({
    required super.id,
    required super.name,
    required super.dosage,
    required super.purpose,
    required super.toBeTakenAt,
    required super.taken,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      purpose: json['purpose'] ?? '',
      toBeTakenAt: json['toBeTakenAt'] != null ? DateTime.parse(json['toBeTakenAt']).toLocal() : DateTime.now(),
      taken: json['taken'] ?? false,
    );
  }
}
