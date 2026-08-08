import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/home/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/home/domain/repositories/home_metrics_repository.dart';
import 'package:yelima/features/reading_logging/domain/entities/reading_form_data.dart';
import 'package:yelima/features/reading_logging/domain/usecases/save_vital_reading_usecase.dart';

class MockHomeMetricsRepository extends Mock implements HomeMetricsRepository {}

class FakeVitalHistoryEntity extends Fake implements VitalHistoryEntity {}

void main() {
  late SaveVitalReadingUseCase useCase;
  late MockHomeMetricsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeVitalHistoryEntity());
  });

  setUp(() {
    mockRepository = MockHomeMetricsRepository();
    useCase = SaveVitalReadingUseCase(mockRepository);

    when(() => mockRepository.saveVitalReading(any())).thenAnswer(
      (_) async => const Right(null),
    );
  });

  group('Blood Pressure Severity Logic', () {
    test('should classify sys < 90 or dia < 60 as low', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 89, diastolic: 65, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.first as VitalHistoryEntity).severity, 'low');

      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 120, diastolic: 59, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'low');
    });

    test('should classify sys >= 180 or dia >= 120 as crisis', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 180, diastolic: 80, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'crisis');

      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 130, diastolic: 120, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'crisis');
    });

    test('should classify sys >= 140 or dia >= 90 as critical', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 140, diastolic: 85, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'critical');
    });

    test('should classify sys >= 130 or dia >= 80 as elevated', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 130, diastolic: 79, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'elevated');
    });

    test('should classify 120/80 correctly', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 120, diastolic: 80, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'elevated'); // >= 80 is elevated
    });

    test('should classify <130/<80 as normal', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 120, diastolic: 79, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'normal');
    });
  });

  group('Blood Sugar Severity Logic', () {
    test('should classify < 4.0 as low regardless of subtype', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 3.9, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'low');
    });

    test('fasting thresholds', () async {
      // Normal <= 5.4
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 5.4, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'normal');

      // Elevated <= 7.0
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 7.0, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'elevated');

      // Critical > 7.0
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 7.1, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'critical');
    });

    test('postprandial/random thresholds', () async {
      // Normal <= 7.8
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 7.8, vitalSubType: 'postprandial', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'normal');

      // Elevated <= 11.1
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 11.1, vitalSubType: 'random', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'elevated');

      // Critical > 11.1
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 11.2, vitalSubType: 'postprandial', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'critical');
    });
  });
}
