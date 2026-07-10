import 'package:uuid/uuid.dart';
import '../../../../core/utils/custom_types.dart';
import '../../../home/domain/entities/vital_history_entity.dart';
import '../../../home/domain/repositories/home_metrics_repository.dart';
import '../entities/reading_form_data.dart';

class SaveVitalReadingUseCase {
  final HomeMetricsRepository repository;

  const SaveVitalReadingUseCase(this.repository);

  AsyncResponse<void> call(ReadingFormData data) async {
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
        severity: _calculateBPSeverity(data.systolic, data.diastolic),
        recordedAt: data.recordedAt,
      );
    } else {
      // Blood Glucose
      entity = VitalHistoryEntity(
        id: uuid,
        vitalType: 'bloodSugar',
        vitalName: 'Blood Sugar',
        value: data.sugarLevel.toStringAsFixed(1),
        unit: 'mmol/L',
        severity: _calculateGlucoseSeverity(data.sugarLevel),
        recordedAt: data.recordedAt,
      );
    }

    return repository.saveVitalReading(entity);
  }

  String _calculateBPSeverity(int sys, int dia) {
    if (sys < 120 && dia < 80) return 'normal';
    if (sys >= 120 && sys <= 129 && dia < 80) return 'elevated';
    if (sys >= 130 || dia >= 80) return 'high';
    return 'normal';
  }

  String _calculateGlucoseSeverity(double level) {
    if (level < 4.0) return 'low';
    if (level >= 4.0 && level <= 5.4) return 'normal';
    return 'high';
  }
}
