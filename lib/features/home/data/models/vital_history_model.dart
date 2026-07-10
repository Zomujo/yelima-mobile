import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drift/drift.dart' as drift;
import '../../domain/entities/vital_history_entity.dart';
import '../../../../core/db/app_database.dart';

part 'vital_history_model.g.dart';

@JsonSerializable()
class VitalHistoryModel extends VitalHistoryEntity {
  const VitalHistoryModel({
    required super.id,
    required super.vitalType,
    required super.value,
    required super.unit,
    required super.severity,
    required super.vitalName,
    super.recordedAt,
  });

  factory VitalHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$VitalHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalHistoryModelToJson(this);

  factory VitalHistoryModel.fromDrift(VitalHistory vitalHistory) {
    return VitalHistoryModel(
      id: vitalHistory.id,
      vitalType: vitalHistory.vitalType,
      value: vitalHistory.value,
      unit: vitalHistory.unit,
      severity: vitalHistory.severity,
      vitalName: vitalHistory.vitalName,
      recordedAt: vitalHistory.recordedAt,
    );
  }

  VitalHistoriesCompanion toDrift() {
    return VitalHistoriesCompanion.insert(
      id: id,
      vitalType: vitalType,
      value: value,
      unit: unit,
      severity: severity,
      vitalName: vitalName,
      recordedAt: drift.Value(recordedAt),
    );
  }
}
