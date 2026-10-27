// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicationDetailModel _$MedicationDetailModelFromJson(
        Map<String, dynamic> json) =>
    _MedicationDetailModel(
      id: _readId(json, 'id') as String,
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
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MedicationDetailModelToJson(
        _MedicationDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'dosage': instance.dosage,
      if (instance.notes case final value?) 'notes': value,
      if (instance.morning?.toJson() case final value?) 'morning': value,
      if (instance.afternoon?.toJson() case final value?) 'afternoon': value,
      if (instance.evening?.toJson() case final value?) 'evening': value,
      if (instance.startDate?.toIso8601String() case final value?)
        'startDate': value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
