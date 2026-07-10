// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_medication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateMedicationModel _$CreateMedicationModelFromJson(
        Map<String, dynamic> json) =>
    _CreateMedicationModel(
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      notes: json['notes'] as String?,
      morning: json['morning'] == null
          ? null
          : DosingScheduleModel.fromJson(
              json['morning'] as Map<String, dynamic>),
      afternoon: json['afternoon'] == null
          ? null
          : DosingScheduleModel.fromJson(
              json['afternoon'] as Map<String, dynamic>),
      evening: json['evening'] == null
          ? null
          : DosingScheduleModel.fromJson(
              json['evening'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateMedicationModelToJson(
        _CreateMedicationModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dosage': instance.dosage,
      if (instance.notes case final value?) 'notes': value,
      if (instance.morning?.toJson() case final value?) 'morning': value,
      if (instance.afternoon?.toJson() case final value?) 'afternoon': value,
      if (instance.evening?.toJson() case final value?) 'evening': value,
    };
