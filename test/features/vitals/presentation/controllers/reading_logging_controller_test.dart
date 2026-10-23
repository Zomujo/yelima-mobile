import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/home/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/home/domain/repositories/home_metrics_repository.dart';
import 'package:yelima/features/reading_logging/domain/usecases/save_vital_reading_usecase.dart';
import 'package:yelima/features/reading_logging/presentation/controllers/reading_logging_controller.dart';

class MockRepo extends Mock implements HomeMetricsRepository {}

void main() {
  late MockRepo repo;

  ReadingLoggingController withLast(String? bp, String? sugar) {
    final metrics = HomeMetricsEntity(bloodPressure: bp, bloodGlucose: sugar);
    when(() => repo.getCachedHomeMetrics())
        .thenAnswer((_) async => right(metrics));
    when(() => repo.getHomeMetrics()).thenAnswer((_) async => right(metrics));
    return ReadingLoggingController(
        repository: repo,
        saveVitalReadingUseCase: SaveVitalReadingUseCase(repo));
  }

  setUp(() => repo = MockRepo());

  test('prefills the form with the last reading', () async {
    final c = withLast('135/85', '6.2');

    await c.init();

    expect((c.state.systolic, c.state.diastolic, c.state.sugarLevel),
        (135, 85, 6.2));
  });

  test('VIT-EC-12/13: skips last readings the pickers can\'t show', () async {
    final c = withLast('300/20', '126');

    await c.init();

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
