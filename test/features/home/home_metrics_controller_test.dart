import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/core_providers.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/services/day_changes.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/features/home/presentation/controllers/home_metrics_controller.dart';
import 'package:yelima/features/home/presentation/states/home_metrics_state.dart';
import 'package:yelima/features/medications/domain/entities/medication_adherence.dart';
import 'package:yelima/features/medications/domain/repositories/medication_repository.dart';
import 'package:yelima/features/medications/medications_providers.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/repositories/vitals_repository.dart';
import 'package:yelima/features/vitals/vitals_providers.dart';

class MockVitals extends Mock implements VitalsRepository {}

class MockMedications extends Mock implements MedicationRepository {}

/// Date changes the test fires by hand.
class FakeDays extends Fake implements DayChanges {
  final _days = StreamController<void>.broadcast();

  @override
  Stream<void> get stream => _days.stream;

  void newDay() => _days.add(null);
}

void main() {
  late MockVitals vitals;
  late MockMedications medications;
  late StreamController<MedicationAdherence?> rate;
  late StreamController<LatestVitals> latest;
  late ProviderContainer container;
  late SessionLifecycleService session;
  late FakeDays days;
  late StreamController<void> synced;
  final now = DateTime.now();
  MedicationAdherence saved(double rate, DateTime at) =>
      MedicationAdherence(rate: rate, days: const [], savedAt: at);
  void serverAnswers(MedicationAdherence a) {
    when(() => vitals.refresh()).thenAnswer((_) async => right(null));
    when(() => medications.getAdherence()).thenAnswer((_) async => right(a));
  }

  /// Starts home's controller in a fresh container.
  ProviderContainer open() => ProviderContainer(overrides: [
        vitalsRepositoryProvider.overrideWithValue(vitals),
        medicationRepositoryProvider.overrideWithValue(medications),
        dayChangesProvider.overrideWithValue(days),
        sessionLifecycleProvider.overrideWithValue(session),
      ])
        ..read(homeMetricsControllerProvider);

  setUp(() async {
    vitals = MockVitals();
    medications = MockMedications();
    rate = StreamController<MedicationAdherence?>.broadcast();
    latest = StreamController<LatestVitals>.broadcast();
    when(() => vitals.watchLatest()).thenAnswer((_) => latest.stream);
    when(() => medications.watchAdherence()).thenAnswer((_) => rate.stream);
    synced = StreamController<void>.broadcast();
    when(() => medications.onSynced).thenAnswer((_) => synced.stream);
    days = FakeDays();
    session = SessionLifecycleService();
    // The opening fetch stays unanswered, so each test starts before the server replies.
    when(() => vitals.refresh()).thenAnswer((_) async => right(null));
    when(() => medications.getAdherence()).thenAnswer(
        (_) => Completer<Either<AppFailure, MedicationAdherence>>().future);
    container = open();
    await pumpEventQueue();
    clearInteractions(vitals);
    clearInteractions(medications);
  });

  tearDown(() => container.dispose());

  HomeMetricsState state() => container.read(homeMetricsControllerProvider);
  HomeMetricsController controller() =>
      container.read(homeMetricsControllerProvider.notifier);

  test('opening home asks both features for fresh data', () async {
    addTearDown(open().dispose);
    await pumpEventQueue();

    verify(() => vitals.refresh()).called(1);
    verify(() => medications.getAdherence()).called(1);
  });

  test('signing out clears the cards', () async {
    latest.add(const LatestVitals());
    rate.add(saved(75, now));
    await pumpEventQueue();
    expect(state().adherence, 0.75);

    await session.startSession('u');
    await session.endSession();

    expect(state(), const HomeMetricsState());
  });

  test('shows loading until the phone\'s readings arrive', () async {
    expect(state().vitals, isNull);

    latest.add(const LatestVitals());
    await pumpEventQueue();

    expect(state().vitals, const LatestVitals());
  });

  test('a figure saved today shows straight away, as a fraction', () async {
    rate.add(saved(75, now));
    await pumpEventQueue();

    expect(state().adherence, 0.75);
  });

  test('a figure saved on an earlier day waits for the server', () async {
    rate.add(saved(37, now.subtract(const Duration(days: 2))));
    await pumpEventQueue();
    expect(state().adherence, isNull);

    serverAnswers(saved(92, now));
    rate.add(saved(92, now)); // the server's answer is saved on the phone
    await controller().fetchMetrics();

    expect(state().adherence, 0.92);
  });

  test('offline, the older figure shows once the server could not answer',
      () async {
    final old = saved(37, now.subtract(const Duration(days: 2)));
    rate.add(old);
    serverAnswers(old);

    await controller().fetchMetrics();

    expect(state().adherence, 0.37);
  });

  test('a new day hides yesterday\'s figure and asks the server', () async {
    final yesterday = saved(85, now.subtract(const Duration(days: 1)));
    serverAnswers(yesterday);
    rate.add(yesterday);
    await controller().fetchMetrics();
    expect(state().adherence, 0.85);

    final answer = Completer<Either<AppFailure, MedicationAdherence>>();
    when(() => medications.getAdherence()).thenAnswer((_) => answer.future);
    days.newDay();
    await pumpEventQueue();

    expect(state().adherence, isNull);
    verify(() => medications.getAdherence()).called(2);
    answer.complete(right(saved(40, now)));
  });

  test('a dose that syncs late asks the server for the new figure', () async {
    serverAnswers(saved(92, now));

    synced.add(null);
    await pumpEventQueue();

    verify(() => medications.getAdherence()).called(1);
  });

  test('nothing saved and no server answer shows 0', () async {
    rate.add(null);
    serverAnswers(const MedicationAdherence(rate: 0, days: []));

    await controller().fetchMetrics();

    expect(state().adherence, 0);
  });

  test('refreshing asks both features for fresh data', () async {
    serverAnswers(const MedicationAdherence(rate: 0, days: []));

    await controller().fetchMetrics();

    verify(() => vitals.refresh()).called(1);
    verify(() => medications.getAdherence()).called(1);
  });
}
