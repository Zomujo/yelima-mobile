import 'package:freezed_annotation/freezed_annotation.dart';

import '../entities/medication_form.dart';

part 'dosing_schedule_model.freezed.dart';
part 'dosing_schedule_model.g.dart';

/// A dose time as the server sends it: 12-hour clock with AM/PM.
@freezed
abstract class ScheduleTimeModel with _$ScheduleTimeModel {
  const ScheduleTimeModel._();

  const factory ScheduleTimeModel({
    required int hour,
    required int minutes,
    required String timeDesignators,
  }) = _ScheduleTimeModel;

  /// [hour] (0-23) on the 12-hour clock.
  factory ScheduleTimeModel.from24(int hour, int minute) => ScheduleTimeModel(
        hour: hour % 12 == 0 ? 12 : hour % 12,
        minutes: minute,
        timeDesignators: hour < 12 ? 'AM' : 'PM',
      );

  /// The hour on the 24-hour clock; 12 AM is 0 and 12 PM is 12.
  int get hour24 =>
      hour % 12 + (timeDesignators.toUpperCase() == 'PM' ? 12 : 0);

  factory ScheduleTimeModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleTimeModelFromJson(json);
}

/// How much to take per dose.
@freezed
abstract class ScheduleQuantityModel with _$ScheduleQuantityModel {
  const factory ScheduleQuantityModel({
    required int value,
    required String unit,
  }) = _ScheduleQuantityModel;

  factory ScheduleQuantityModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleQuantityModelFromJson(json);
}

/// One dose slot as the server stores it.
@freezed
abstract class DosingScheduleModel with _$DosingScheduleModel {
  const DosingScheduleModel._();

  const factory DosingScheduleModel({
    required ScheduleTimeModel time,
    required ScheduleQuantityModel quantity,
  }) = _DosingScheduleModel;

  /// [dose] in the server's format.
  factory DosingScheduleModel.fromDose(DoseSchedule dose, String unit) =>
      DosingScheduleModel(
        time: ScheduleTimeModel.from24(dose.hour, dose.minute),
        quantity: ScheduleQuantityModel(value: dose.quantity, unit: unit),
      );

  /// This slot on the 24-hour clock.
  DoseSchedule toDose() => DoseSchedule(
      hour: time.hour24, minute: time.minutes, quantity: quantity.value);

  factory DosingScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$DosingScheduleModelFromJson(json);
}
