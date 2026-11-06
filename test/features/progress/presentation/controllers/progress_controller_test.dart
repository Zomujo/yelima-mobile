import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/core_providers.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/features/progress/domain/entities/vital_trends.dart';
import 'package:yelima/features/progress/domain/repositories/progress_repository.dart';
import 'package:yelima/features/progress/presentation/controllers/progress_controller.dart';
import 'package:yelima/features/progress/presentation/controllers/progress_state.dart';
import 'package:yelima/features/progress/progress_providers.dart';

class MockRepo extends Mock implements ProgressRepository {}

void main() {
  late MockRepo repo;
  late SessionLifecycleService session;
  late ProviderContainer container;
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
    session = SessionLifecycleService();
    container = ProviderContainer(overrides: [
      progressRepositoryProvider.overrideWithValue(repo),
      sessionLifecycleProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);
  });

  ProgressController controller() =>
      container.read(progressControllerProvider.notifier);
  ProgressCharts charts() => container.read(progressControllerProvider);

  test('loads both charts', () async {
    await controller().load(today);

    expect(charts().bpTrendState.data, bp);
    expect(charts().glucoseTrendState.data, sugar);
    expect(charts().bpTrendState.isLoading, isFalse);
  });

  test('a failure with nothing cached shows the error', () async {
    when(() => repo.getBPTrend(any()))
        .thenAnswer((_) async => left(const NetworkFailure()));

    await controller().load(today);

    expect(charts().bpTrendState.data, isNull);
    expect(charts().bpTrendState.error, const NetworkFailure());
  });

  test('the cached chart stays when the refresh fails', () async {
    when(() => repo.getCachedBPTrend(today)).thenAnswer((_) async => right(bp));
    when(() => repo.getBPTrend(today))
        .thenAnswer((_) async => left(const NetworkFailure()));

    await controller().load(today);

    expect(charts().bpTrendState.data, bp);
    expect(charts().bpTrendState.error, const NetworkFailure());
  });

  test('an answer for a range the user left is ignored', () async {
    final slow = Completer<Either<AppFailure, BPTrend>>();
    when(() => repo.getBPTrend(today)).thenAnswer((_) => slow.future);
    const month = BPTrend(
        labels: ['2026-10-01T10:00:00Z'], systolic: [130], diastolic: [85]);
    when(() => repo.getBPTrend(ChartDateRange.thisMonth))
        .thenAnswer((_) async => right(month));

    final first = controller().load(today);
    await controller().load(ChartDateRange.thisMonth);
    slow.complete(right(bp));
    await first;

    expect(charts().bpTrendState.data, month);
  });

  test('switching to a cached range never blanks the chart', () async {
    const month = BPTrend(
        labels: ['2026-10-01T10:00:00Z'], systolic: [130], diastolic: [85]);
    when(() => repo.getCachedBPTrend(ChartDateRange.thisMonth))
        .thenAnswer((_) async => right(month));
    await controller().load(today);
    final shown = <BPTrend?>[];
    container.listen(progressControllerProvider.select((s) => s.bpTrendState),
        (_, s) => shown.add(s.data));

    await controller().load(ChartDateRange.thisMonth);

    expect(shown, isNot(contains(null)));
    expect(shown.first, month);
  });

  test('signing out clears both charts', () async {
    await controller().load(today);

    await session.startSession('u');
    await session.endSession();

    expect(charts(), const ProgressCharts());
    expect(charts().bpTrendState.isLoading, isTrue);
  });

  test('a chart still loading when the user signs out is dropped', () async {
    final slow = Completer<Either<AppFailure, BPTrend>>();
    when(() => repo.getBPTrend(today)).thenAnswer((_) => slow.future);

    final load = controller().load(today);
    await session.startSession('u');
    await session.endSession();
    slow.complete(right(bp));
    await load;

    expect(charts().bpTrendState.data, isNull);
  });
}
