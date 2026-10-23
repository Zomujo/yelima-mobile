import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drift/drift.dart' as drift;
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/core/db/app_database.dart';

part 'vital_history_model.g.dart';

/// A reading as the server sends it and as a local row.
@JsonSerializable()
class VitalHistoryModel extends VitalHistoryEntity {
  const VitalHistoryModel({
    required super.id,
    required super.vitalType,
    required super.value,
    required super.unit,
    required super.severity,
    required super.vitalName,
    super.vitalSubType,
    super.recordedAt,
  });

  factory VitalHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$VitalHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalHistoryModelToJson(this);

  /// [entity] as a model.
  factory VitalHistoryModel.fromEntity(VitalHistoryEntity entity) =>
      VitalHistoryModel(
        id: entity.id,
        vitalType: entity.vitalType,
        value: entity.value,
        unit: entity.unit,
        severity: entity.severity,
        vitalName: entity.vitalName,
        vitalSubType: entity.vitalSubType,
        recordedAt: entity.recordedAt,
      );

  factory VitalHistoryModel.fromDrift(VitalHistory vitalHistory) {
    return VitalHistoryModel(
      id: vitalHistory.id,
      vitalType: vitalHistory.vitalType,
      value: vitalHistory.value,
      unit: vitalHistory.unit,
      severity: vitalHistory.severity,
      vitalName: vitalHistory.vitalName,
      vitalSubType: vitalHistory.vitalSubType,
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
      vitalSubType: drift.Value(vitalSubType),
      recordedAt: drift.Value(recordedAt),
    );
  }
}
