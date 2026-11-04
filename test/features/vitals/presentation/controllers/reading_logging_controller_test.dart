import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/vitals/domain/entities/reading_form.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/repositories/vitals_repository.dart';
import 'package:yelima/features/vitals/presentation/controllers/reading_logging_controller.dart';
import 'package:yelima/features/vitals/presentation/states/reading_logging_state.dart';
import 'package:yelima/features/vitals/vitals_providers.dart';

class MockRepo extends Mock implements VitalsRepository {}

void main() {
  late MockRepo repo;

  VitalHistoryEntity reading(String type, String value) => VitalHistoryEntity(
      id: value,
      vitalType: type,
      value: value,
      unit: '',
      severity: 'normal',
      vitalName: '');

  late ProviderContainer container;

  ReadingLoggingState state() => container.read(readingLoggingControllerProvider);

  /// Opens the form with [bp] and [sugar] as the last saved readings.
  Future<ReadingLoggingController> withLast(String bp, String sugar) async {
    when(() => repo.watchReadings()).thenAnswer((_) => Stream.value(
        [reading('bloodPressure', bp), reading('bloodSugar', sugar)]));
    when(() => repo.refresh()).thenAnswer((_) async => right(null));
    container = ProviderContainer(
        overrides: [vitalsRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    container.listen(readingLoggingControllerProvider, (_, __) {});
    await pumpEventQueue();
    return container.read(readingLoggingControllerProvider.notifier);
  }

  setUp(() => repo = MockRepo());

  setUpAll(() => registerFallbackValue(ReadingForm(
      kind: VitalKind.bloodPressure,
      systolic: 120,
      diastolic: 80,
      sugarLevel: 5.5,
      recordedAt: DateTime(2026))));

  test('prefills the form with the last reading', () async {
    await withLast('135/85', '6.2');

    expect((state().systolic, state().diastolic, state().sugarLevel),
        (135, 85, 6.2));
    expect(state().history?.length, 2);
    verify(() => repo.refresh()).called(1);
  });

  test('VIT-EC-12/13: skips last readings the pickers can\'t show', () async {
    await withLast('300/20', '126');

    expect((
      state().systolic,
      state().diastolic,
      state().sugarLevel
    ), (
      120,
      80,
      5.5
    ), reason: 'keeps the defaults');
  });

  test('a reading is timed when it is saved, not when the screen opened',
      () async {
    final c = await withClock(Clock.fixed(DateTime(2026, 11, 2, 14, 58)),
        () => withLast('120/80', '5.5'));
    when(() => repo.saveReading(any()))
        .thenAnswer((_) async => right(VitalSeverity.normal));

    await withClock(
        Clock.fixed(DateTime(2026, 11, 2, 15, 6)), () => c.saveReading());

    final saved = verify(() => repo.saveReading(captureAny())).captured.single
        as ReadingForm;
    expect(saved.recordedAt, DateTime(2026, 11, 2, 15, 6));
  });
}
