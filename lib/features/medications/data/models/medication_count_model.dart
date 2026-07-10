import '../../domain/entities/medication_count.dart';

class MedicationCountModel extends MedicationCount {
  const MedicationCountModel({
    required super.morning,
    required super.afternoon,
    required super.evening,
  });

  factory MedicationCountModel.fromJson(Map<String, dynamic> json) {
    return MedicationCountModel(
      morning: json['morning'] ?? 0,
      afternoon: json['afternoon'] ?? 0,
      evening: json['evening'] ?? 0,
    );
  }
}
