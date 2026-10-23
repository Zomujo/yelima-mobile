import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/repositories/vitals_repository.dart';
import 'package:yelima/features/vitals/domain/entities/reading_form_data.dart';
import 'package:yelima/features/vitals/domain/usecases/save_vital_reading_usecase.dart';

class MockHomeMetricsRepository extends Mock implements VitalsRepository {}

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

  Future<VitalHistoryEntity> save(ReadingFormData data) async {
    await useCase(data);
    return verify(() => mockRepository.saveVitalReading(captureAny()))
        .captured
        .last as VitalHistoryEntity;
  }

  ReadingFormData bp(int sys, int dia) => ReadingFormData(
      selectedTypeIndex: 0,
      systolic: sys,
      diastolic: dia,
      sugarLevel: 0,
      recordedAt: DateTime(2026, 10, 23, 8));

  ReadingFormData sugar(double level, String subType) => ReadingFormData(
      selectedTypeIndex: 1,
      systolic: 0,
      diastolic: 0,
      sugarLevel: level,
      vitalSubType: subType,
      recordedAt: DateTime(2026, 10, 23, 8));

  test('a BP reading is saved with the server\'s grade and shape', () async {
    final v = await save(bp(185, 125));

    expect((v.vitalType, v.value, v.unit, v.severity),
        ('bloodPressure', '185/125', 'mmHg', 'hypertensive_crisis'));
    expect(v.recordedAt, DateTime(2026, 10, 23, 8));
  });

  test('low blood pressure is graded now (it used to show as good)', () async {
    expect((await save(bp(85, 55))).severity, 'hypotensive');
  });

  test('a sugar reading is saved in mmol/L with the server\'s grade', () async {
    final v = await save(sugar(5.25, 'fasting'));

    expect((v.vitalType, v.value, v.unit, v.vitalSubType, v.severity),
        ('bloodSugar', '5.3', 'mmol/L', 'fasting', 'normal'));
  });

  test(
      'post-meal 13.9 and above is critically high, like fasting (no subtype split)',
      () async {
    expect(
        (await save(sugar(15.0, 'postprandial'))).severity, 'critically_high');
    expect((await save(sugar(15.0, 'fasting'))).severity, 'critically_high');
  });

  group('validation', () {
    Future<void> expectRejected(ReadingFormData data, String text) async {
      final result = await useCase(data);

      expect(result.getLeft().toNullable(), contains(text));
      verifyNever(() => mockRepository.saveVitalReading(any()));
    }

    test('VIT-EC-11: systolic must be above diastolic', () async {
      await expectRejected(bp(90, 120), 'top number');
      await expectRejected(bp(100, 100), 'top number');
    });

    test('VIT-EC-12: out-of-range blood pressure is refused', () async {
      await expectRejected(bp(300, 20), 'between');
    });

    test('VIT-EC-13: a mg/dL number is not saved as mmol/L', () async {
      await expectRejected(sugar(126, 'fasting'), 'between');
    });

    test('values at the limits are accepted', () async {
      await useCase(bp(250, 150));
      await useCase(sugar(1.0, 'fasting'));

      verify(() => mockRepository.saveVitalReading(any())).called(2);
    });
  });
}
