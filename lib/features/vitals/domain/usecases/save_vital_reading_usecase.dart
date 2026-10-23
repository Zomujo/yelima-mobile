import 'package:uuid/uuid.dart';
import 'package:yelima/core/utils/custom_types.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/repositories/vitals_repository.dart';
import 'package:yelima/features/vitals/domain/entities/reading_form_data.dart';
import 'package:yelima/features/vitals/domain/reading_limits.dart';
import 'package:yelima/features/vitals/domain/vital_severity_thresholds.dart';
import 'package:fpdart/fpdart.dart';

/// Builds a reading from the form, grades it with the backend's table, and saves it.
class SaveVitalReadingUseCase {
  final VitalsRepository repository;

  const SaveVitalReadingUseCase(this.repository);

  AsyncResponse<void> call(ReadingFormData data) async {
    // Never save an impossible reading (e.g. 90/120, or a mg/dL number as mmol/L).
    final error = data.selectedTypeIndex == 0
        ? ReadingLimits.bloodPressureError(data.systolic, data.diastolic)
        : ReadingLimits.bloodSugarError(data.sugarLevel);
    if (error != null) return left(error.message);

    late VitalHistoryEntity entity;
    final uuid = const Uuid().v4();

    if (data.selectedTypeIndex == 0) {
      // Blood Pressure
      entity = VitalHistoryEntity(
        id: uuid,
        vitalType: 'bloodPressure',
        vitalName: 'Blood Pressure',
        value: '${data.systolic}/${data.diastolic}',
        unit: 'mmHg',
        severity: VitalSeverityThresholds.bloodPressure(
            data.systolic, data.diastolic),
        recordedAt: data.recordedAt,
      );
    } else {
      // Blood Glucose
      entity = VitalHistoryEntity(
        id: uuid,
        vitalType: 'bloodSugar',
        vitalName: 'Blood Sugar',
        vitalSubType: data.vitalSubType,
        value: data.sugarLevel.toStringAsFixed(1),
        unit: 'mmol/L',
        severity: VitalSeverityThresholds.bloodSugar(data.sugarLevel),
        recordedAt: data.recordedAt,
      );
    }

    return repository.saveVitalReading(entity);
  }
}
