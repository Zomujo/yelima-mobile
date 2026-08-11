import '../../domain/entities/symptom_entity.dart';

class SymptomModel extends SymptomEntity {
  const SymptomModel({
    required super.id,
    required super.description,
    required super.onsetDate,
  });

  factory SymptomModel.fromJson(Map<String, dynamic> json) {
    return SymptomModel(
      id: json['id'] ?? json['_id'] ?? '',
      description: json['description'] ?? '',
      onsetDate: json['onsetDate'] != null
          ? DateTime.parse(json['onsetDate']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'onsetDate': onsetDate.toUtc().toIso8601String(),
    };
  }
}
