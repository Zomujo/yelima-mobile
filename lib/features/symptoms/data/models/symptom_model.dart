import 'package:clock/clock.dart';

import '../../domain/entities/symptom_entity.dart';

/// A symptom as the server sends it.
class SymptomModel extends SymptomEntity {
  const SymptomModel(
      {required super.id,
      required super.description,
      required super.onsetDate});

  factory SymptomModel.fromJson(Map<String, dynamic> json) => SymptomModel(
        id: json['id'] ?? json['_id'] ?? '',
        description: json['description'] ?? '',
        onsetDate: json['onsetDate'] == null
            ? clock.now()
            : DateTime.parse(json['onsetDate']).toLocal(),
      );
}
