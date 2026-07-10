import 'package:freezed_annotation/freezed_annotation.dart';
import 'dosing_schedule_model.dart';

part 'update_medication_model.freezed.dart';
part 'update_medication_model.g.dart';

@freezed
abstract class UpdateMedicationModel with _$UpdateMedicationModel {
  const factory UpdateMedicationModel({
    String? dosage,
    String? notes,
    DosingScheduleModel? morning,
    DosingScheduleModel? afternoon,
    DosingScheduleModel? evening,
  }) = _UpdateMedicationModel;

  factory UpdateMedicationModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateMedicationModelFromJson(json);
}
