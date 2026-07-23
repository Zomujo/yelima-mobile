// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seeded_medication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SeededMedicationModel _$SeededMedicationModelFromJson(
        Map<String, dynamic> json) =>
    _SeededMedicationModel(
      id: _readId(json, 'id') as String,
      name: json['name'] as String,
      possibleDosages: (json['possibleDosages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SeededMedicationModelToJson(
        _SeededMedicationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'possibleDosages': instance.possibleDosages,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
