// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vital_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VitalHistoryModel _$VitalHistoryModelFromJson(Map<String, dynamic> json) =>
    VitalHistoryModel(
      id: json['id'] as String,
      vitalType: json['vitalType'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
      severity: json['severity'] as String,
      vitalName: json['vitalName'] as String,
      recordedAt: json['recordedAt'] == null
          ? null
          : DateTime.parse(json['recordedAt'] as String),
    );

Map<String, dynamic> _$VitalHistoryModelToJson(VitalHistoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vitalType': instance.vitalType,
      'value': instance.value,
      'unit': instance.unit,
      'severity': instance.severity,
      'vitalName': instance.vitalName,
      if (instance.recordedAt?.toIso8601String() case final value?)
        'recordedAt': value,
    };
