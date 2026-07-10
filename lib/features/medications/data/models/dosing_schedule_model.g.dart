// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dosing_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleTimeModel _$ScheduleTimeModelFromJson(Map<String, dynamic> json) =>
    _ScheduleTimeModel(
      hour: (json['hour'] as num).toInt(),
      minutes: (json['minutes'] as num).toInt(),
      timeDesignators: json['timeDesignators'] as String,
    );

Map<String, dynamic> _$ScheduleTimeModelToJson(_ScheduleTimeModel instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minutes': instance.minutes,
      'timeDesignators': instance.timeDesignators,
    };

_ScheduleQuantityModel _$ScheduleQuantityModelFromJson(
        Map<String, dynamic> json) =>
    _ScheduleQuantityModel(
      value: (json['value'] as num).toInt(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$ScheduleQuantityModelToJson(
        _ScheduleQuantityModel instance) =>
    <String, dynamic>{
      'value': instance.value,
      'unit': instance.unit,
    };

_DosingScheduleModel _$DosingScheduleModelFromJson(Map<String, dynamic> json) =>
    _DosingScheduleModel(
      time: ScheduleTimeModel.fromJson(json['time'] as Map<String, dynamic>),
      quantity: ScheduleQuantityModel.fromJson(
          json['quantity'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DosingScheduleModelToJson(
        _DosingScheduleModel instance) =>
    <String, dynamic>{
      'time': instance.time.toJson(),
      'quantity': instance.quantity.toJson(),
    };
