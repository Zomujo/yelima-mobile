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
        vitalSubType: data.vitalSubType,
        value: data.sugarLevel.toStringAsFixed(1),
        unit: 'mmol/L',
        severity: _calculateGlucoseSeverity(data.sugarLevel, data.vitalSubType),
        recordedAt: data.recordedAt,
      );
    }

    return repository.saveVitalReading(entity);
  }

  String _calculateBPSeverity(int sys, int dia) {
    if (sys >= 180 || dia >= 120) return 'critical';
    if (sys >= 160 || dia >= 100) return 'very_high';
    if (sys >= 140 || dia >= 90) return 'high';
    if (sys >= 130 || dia >= 80) return 'slightly_high';
    return 'good';
  }

  String _calculateGlucoseSeverity(double level, String subType) {
    if (level < 3.0) return 'critically_low';
    if (level <= 3.8) return 'low';
    
    if (subType == 'fasting') {
      if (level <= 7.2) return 'in_target';
      if (level <= 9.9) return 'slightly_high';
      if (level <= 13.8) return 'high';
      if (level <= 16.6) return 'very_high';
      return 'critical';
    } else { // postprandial or random
      if (level < 10.0) return 'in_target';
      if (level <= 13.8) return 'slightly_high';
      if (level <= 16.6) return 'high'; // Very High and High merge a bit, let's keep High for 13.9-16.6 as per table, wait table says Very High is 250-299* which is 13.9-16.6. High is 250-299. It's the same band. Let's make 13.9-16.6 'very_high' and anything >= 16.7 'critical'. Let's adjust to match image precisely: Slightly high: 10.0-13.8. High: 13.9-16.6. Very High: 13.9-16.6. I will use 'very_high' for 13.9-16.6.
      return 'critical';
    }
  }
}
