import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/features/home/presentation/controllers/home_metrics_controller.dart';
import 'package:yelima/features/medications/domain/entities/medication_adherence.dart';
import 'package:yelima/features/medications/domain/repositories/medication_repository.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/repositories/vitals_repository.dart';

class MockVitals extends Mock implements VitalsRepository {}

class MockMedications extends Mock implements MedicationRepository {}

void main() {
  late MockVitals vitals;
  late MockMedications medications;
  late StreamController<MedicationAdherence?> rate;
  late StreamController<LatestVitals> latest;
  late HomeMetricsController controller;
  late StreamController<void> newDays;
  late StreamController<void> synced;
  final now = DateTime.now();
  MedicationAdherence saved(double rate, DateTime at) =>
      MedicationAdherence(rate: rate, days: const [], savedAt: at);
  void serverAnswers(MedicationAdherence a) {
    when(() => vitals.refresh()).thenAnswer((_) async => right(null));
    when(() => medications.getAdherence()).thenAnswer((_) async => right(a));
  }

  setUp(() {
    vitals = MockVitals();
    medications = MockMedications();
    rate = StreamController<MedicationAdherence?>();
    latest = StreamController<LatestVitals>();
    when(() => vitals.watchLatest()).thenAnswer((_) => latest.stream);
    when(() => medications.watchAdherence()).thenAnswer((_) => rate.stream);
    synced = StreamController<void>.broadcast();
    when(() => medications.onSynced).thenAnswer((_) => synced.stream);
    newDays = StreamController<void>.broadcast();
    controller = HomeMetricsController(
        vitals: vitals, medications: medications, newDays: newDays.stream);
  });

  tearDown(() => controller.dispose());

  test('shows loading until the phone\'s readings arrive', () async {
    expect(controller.state.vitals, isNull);

    latest.add(const LatestVitals());
    await pumpEventQueue();

    expect(controller.state.vitals, const LatestVitals());
  });

  test('a figure saved today shows straight away, as a fraction', () async {
    rate.add(saved(75, now));
    await pumpEventQueue();

    expect(controller.state.adherence, 0.75);
  });

  test('a figure saved on an earlier day waits for the server', () async {
    rate.add(saved(37, now.subtract(const Duration(days: 2))));
    await pumpEventQueue();
    expect(controller.state.adherence, isNull);

    serverAnswers(saved(92, now));
    rate.add(saved(92, now)); // the server's answer is saved on the phone
    await controller.fetchMetrics();

    expect(controller.state.adherence, 0.92);
  });

  test('offline, the older figure shows once the server could not answer',
      () async {
    final old = saved(37, now.subtract(const Duration(days: 2)));
    rate.add(old);
    serverAnswers(old);

    await controller.fetchMetrics();

    expect(controller.state.adherence, 0.37);
  });

  test('a new day hides yesterday\'s figure and asks the server', () async {
    final yesterday = saved(85, now.subtract(const Duration(days: 1)));
    serverAnswers(yesterday);
    rate.add(yesterday);
    await controller.fetchMetrics();
    expect(controller.state.adherence, 0.85);

    final answer = Completer<Either<AppFailure, MedicationAdherence>>();
    when(() => medications.getAdherence()).thenAnswer((_) => answer.future);
    newDays.add(null);
    await pumpEventQueue();

    expect(controller.state.adherence, isNull);
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

    await controller.fetchMetrics();

    expect(controller.state.adherence, 0);
  });

  test('refreshing asks both features for fresh data', () async {
    serverAnswers(const MedicationAdherence(rate: 0, days: []));

    await controller.fetchMetrics();

    verify(() => vitals.refresh()).called(1);
    verify(() => medications.getAdherence()).called(1);
  });
}
