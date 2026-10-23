import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yelima/features/medications/domain/models/seeded_medication_model.dart';

part 'package:yelima/features/medications/domain/models/seeded_medication_list_response_model.freezed.dart';
part 'package:yelima/features/medications/domain/models/seeded_medication_list_response_model.g.dart';

@freezed
abstract class SeededMedicationListResponseModel
    with _$SeededMedicationListResponseModel {
  const factory SeededMedicationListResponseModel({
    @Default([]) List<SeededMedicationModel> rows,
    @Default(0) int total,
    @Default(10) int pageSize,
    @Default(1) int page,
    @Default(0) int totalPages,
  }) = _SeededMedicationListResponseModel;

  factory SeededMedicationListResponseModel.fromJson(
          Map<String, dynamic> json) =>
      _$SeededMedicationListResponseModelFromJson(json);
}
