import 'package:freezed_annotation/freezed_annotation.dart';
import 'dosing_schedule_model.dart';

part 'create_medication_model.freezed.dart';
part 'create_medication_model.g.dart';

@freezed
abstract class CreateMedicationModel with _$CreateMedicationModel {
  const factory CreateMedicationModel({
    required String name,
    required String dosage,
    String? notes,
    DosingScheduleModel? morning,
    DosingScheduleModel? afternoon,
    DosingScheduleModel? evening,
  }) = _CreateMedicationModel;

  factory CreateMedicationModel.fromJson(Map<String, dynamic> json) =>
      _$CreateMedicationModelFromJson(json);
}
