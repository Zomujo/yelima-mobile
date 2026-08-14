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
    test('should classify sys >= 180 or dia >= 120 as critical', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 180, diastolic: 80, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'critical');

      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 130, diastolic: 120, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'critical');
    });

    test('should classify sys >= 160 or dia >= 100 as very_high', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 160, diastolic: 85, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'very_high');
    });

    test('should classify sys >= 140 or dia >= 90 as high', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 140, diastolic: 85, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'high');
    });

    test('should classify sys >= 130 or dia >= 80 as slightly_high', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 130, diastolic: 79, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'slightly_high');
    });

    test('should classify <130/<80 as good', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 0, systolic: 120, diastolic: 79, sugarLevel: 0.0, vitalSubType: 'random', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'good');
    });
  });

  group('Blood Sugar Severity Logic', () {
    test('should classify < 3.0 as critically_low', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 2.9, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'critically_low');
    });

    test('should classify <= 3.8 as low', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 3.8, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'low');
    });

    test('fasting thresholds', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 7.2, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'in_target');

      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 9.9, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'slightly_high');

      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 13.8, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'high');
      
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 16.6, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'very_high');
      
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 16.7, vitalSubType: 'fasting', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'critical');
    });

    test('postprandial/random thresholds', () async {
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 9.9, vitalSubType: 'postprandial', recordedAt: DateTime.now()));
      var captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'in_target');

      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 13.8, vitalSubType: 'random', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'slightly_high');

      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 16.6, vitalSubType: 'postprandial', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'high');
      
      await useCase(ReadingFormData(selectedTypeIndex: 1, systolic: 0, diastolic: 0, sugarLevel: 16.7, vitalSubType: 'postprandial', recordedAt: DateTime.now()));
      captured = verify(() => mockRepository.saveVitalReading(captureAny())).captured;
      expect((captured.last as VitalHistoryEntity).severity, 'critical');
    });
  });
}
