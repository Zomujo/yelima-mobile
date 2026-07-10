import 'package:freezed_annotation/freezed_annotation.dart';

part 'seeded_medication_model.freezed.dart';
part 'seeded_medication_model.g.dart';

@freezed
abstract class SeededMedicationModel with _$SeededMedicationModel {
  const factory SeededMedicationModel({
    required String id,
    required String name,
    required List<String> possibleDosages,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SeededMedicationModel;

  factory SeededMedicationModel.fromJson(Map<String, dynamic> json) =>
      _$SeededMedicationModelFromJson(json);
}
