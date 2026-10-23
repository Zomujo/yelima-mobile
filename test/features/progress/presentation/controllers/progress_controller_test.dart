import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/features/progress/domain/entities/vital_trends.dart';
import 'package:yelima/features/progress/domain/repositories/progress_repository.dart';
import 'package:yelima/features/progress/presentation/controllers/progress_controller.dart';

class MockRepo extends Mock implements ProgressRepository {}

void main() {
  late MockRepo repo;
  late ProgressController controller;
  const today = ChartDateRange.today;
  const bp = BPTrend(
      labels: ['2026-10-23T10:00:00Z'], systolic: [120], diastolic: [80]);
  const sugar = VitalTrend(labels: ['2026-10-23T10:00:00Z'], values: [5.5]);

  setUpAll(() => registerFallbackValue(today));

  setUp(() {
    repo = MockRepo();
    when(() => repo.getCachedBPTrend(any()))
        .thenAnswer((_) async => left(const NotFoundFailure()));
    when(() => repo.getCachedSugarTrend(any()))
        .thenAnswer((_) async => left(const NotFoundFailure()));
    when(() => repo.getBPTrend(any())).thenAnswer((_) async => right(bp));
    when(() => repo.getSugarTrend(any())).thenAnswer((_) async => right(sugar));
    controller = ProgressController(repo);
  });

  tearDown(() => controller.dispose());

  test('loads both charts', () async {
    await controller.load(today);

    expect(controller.bpTrendState.data, bp);
    expect(controller.glucoseTrendState.data, sugar);
    expect(controller.bpTrendState.isLoading, isFalse);
  });

  test('a failure with nothing cached shows the error', () async {
    when(() => repo.getBPTrend(any()))
        .thenAnswer((_) async => left(const NetworkFailure()));

    await controller.load(today);

    expect(controller.bpTrendState.data, isNull);
    expect(controller.bpTrendState.error, const NetworkFailure());
  });

  test('the cached chart stays when the refresh fails', () async {
    when(() => repo.getCachedBPTrend(today)).thenAnswer((_) async => right(bp));
    when(() => repo.getBPTrend(today))
        .thenAnswer((_) async => left(const NetworkFailure()));

    await controller.load(today);

    expect(controller.bpTrendState.data, bp);
    expect(controller.bpTrendState.error, const NetworkFailure());
  });

  test('an answer for a range the user left is ignored', () async {
    final slow = Completer<Either<AppFailure, BPTrend>>();
    when(() => repo.getBPTrend(today)).thenAnswer((_) => slow.future);
    const month = BPTrend(
        labels: ['2026-10-01T10:00:00Z'], systolic: [130], diastolic: [85]);
    when(() => repo.getBPTrend(ChartDateRange.thisMonth))
        .thenAnswer((_) async => right(month));

    final first = controller.load(today);
    await controller.load(ChartDateRange.thisMonth);
    slow.complete(right(bp));
    await first;

    expect(controller.bpTrendState.data, month);
  });
}
