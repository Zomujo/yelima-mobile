// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_medication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateMedicationModel _$UpdateMedicationModelFromJson(
        Map<String, dynamic> json) =>
    _UpdateMedicationModel(
      dosage: json['dosage'] as String?,
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

Map<String, dynamic> _$UpdateMedicationModelToJson(
        _UpdateMedicationModel instance) =>
    <String, dynamic>{
      if (instance.dosage case final value?) 'dosage': value,
      if (instance.notes case final value?) 'notes': value,
      if (instance.morning?.toJson() case final value?) 'morning': value,
      if (instance.afternoon?.toJson() case final value?) 'afternoon': value,
      if (instance.evening?.toJson() case final value?) 'evening': value,
    };
