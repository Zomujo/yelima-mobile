import 'package:freezed_annotation/freezed_annotation.dart';
import 'dosing_schedule_model.dart';

part 'medication_detail_model.freezed.dart';
part 'medication_detail_model.g.dart';

Object? _readId(Map json, String key) => json['_id'] ?? json['id'];

@freezed
abstract class MedicationDetailModel with _$MedicationDetailModel {
  const factory MedicationDetailModel({
    @JsonKey(readValue: _readId) required String id,
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
