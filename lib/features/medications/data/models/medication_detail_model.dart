import 'package:freezed_annotation/freezed_annotation.dart';
import 'dosing_schedule_model.dart';

part 'medication_detail_model.freezed.dart';
part 'medication_detail_model.g.dart';

@freezed
abstract class MedicationDetailModel with _$MedicationDetailModel {
  const factory MedicationDetailModel({
    required String id,
    required String name,
    required String dosage,
    String? notes,
    DosingScheduleModel? morning,
    DosingScheduleModel? afternoon,
    DosingScheduleModel? evening,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MedicationDetailModel;

  factory MedicationDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationDetailModelFromJson(json);
}
