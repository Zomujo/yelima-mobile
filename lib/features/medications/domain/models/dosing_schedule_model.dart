import 'package:freezed_annotation/freezed_annotation.dart';

part 'dosing_schedule_model.freezed.dart';
part 'dosing_schedule_model.g.dart';

@freezed
abstract class ScheduleTimeModel with _$ScheduleTimeModel {
  const factory ScheduleTimeModel({
    required int hour,
    required int minutes,
    required String timeDesignators,
  }) = _ScheduleTimeModel;

  factory ScheduleTimeModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleTimeModelFromJson(json);
}

@freezed
abstract class ScheduleQuantityModel with _$ScheduleQuantityModel {
  const factory ScheduleQuantityModel({
    required int value,
    required String unit,
  }) = _ScheduleQuantityModel;

  factory ScheduleQuantityModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleQuantityModelFromJson(json);
}

@freezed
abstract class DosingScheduleModel with _$DosingScheduleModel {
  const factory DosingScheduleModel({
    required ScheduleTimeModel time,
    required ScheduleQuantityModel quantity,
  }) = _DosingScheduleModel;

  factory DosingScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$DosingScheduleModelFromJson(json);
}
