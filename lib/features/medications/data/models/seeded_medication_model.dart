import 'package:freezed_annotation/freezed_annotation.dart';

part 'seeded_medication_model.freezed.dart';
part 'seeded_medication_model.g.dart';

Object? _readId(Map json, String key) => json['_id'] ?? json['id'];

@freezed
abstract class SeededMedicationModel with _$SeededMedicationModel {
  const factory SeededMedicationModel({
    @JsonKey(readValue: _readId) required String id,
    required String name,
    required List<String> possibleDosages,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SeededMedicationModel;

  factory SeededMedicationModel.fromJson(Map<String, dynamic> json) =>
      _$SeededMedicationModelFromJson(json);
}
