import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/repositories/vitals_repository.dart';
import 'package:yelima/features/vitals/presentation/controllers/reading_logging_controller.dart';

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

  Future<ReadingLoggingController> withLast(String bp, String sugar) async {
    when(() => repo.watchReadings()).thenAnswer((_) => Stream.value(
        [reading('bloodPressure', bp), reading('bloodSugar', sugar)]));
    when(() => repo.refresh()).thenAnswer((_) async => right(null));
    final c = ReadingLoggingController(repository: repo)..init();
    await pumpEventQueue();
    return c;
  }

  setUp(() => repo = MockRepo());

  test('prefills the form with the last reading', () async {
    final c = await withLast('135/85', '6.2');

    expect((c.state.systolic, c.state.diastolic, c.state.sugarLevel),
        (135, 85, 6.2));
    expect(c.history?.length, 2);
    verify(() => repo.refresh()).called(1);
  });

  test('VIT-EC-12/13: skips last readings the pickers can\'t show', () async {
    final c = await withLast('300/20', '126');

    expect((
      c.state.systolic,
      c.state.diastolic,
      c.state.sugarLevel
    ), (
      120,
      80,
      5.5
    ), reason: 'keeps the defaults');
  });
}
