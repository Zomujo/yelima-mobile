import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
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
  late StreamController<double?> rate;
  late StreamController<LatestVitals> latest;
  late HomeMetricsController controller;

  setUp(() {
    vitals = MockVitals();
    medications = MockMedications();
    rate = StreamController<double?>();
    latest = StreamController<LatestVitals>();
    when(() => vitals.watchLatest()).thenAnswer((_) => latest.stream);
    when(() => medications.watchAdherenceRate()).thenAnswer((_) => rate.stream);
    controller =
        HomeMetricsController(vitals: vitals, medications: medications);
  });

  tearDown(() => controller.dispose());

  test('shows loading until the phone\'s readings arrive', () async {
    expect(controller.state.vitals, isNull);

    latest.add(const LatestVitals());
    await pumpEventQueue();

    expect(controller.state.vitals, const LatestVitals());
  });

  test('adherence is a fraction, whether the server sent 0–1 or 0–100',
      () async {
    rate.add(75);
    await pumpEventQueue();
    expect(controller.state.adherence, 0.75);

    rate.add(0.5);
    await pumpEventQueue();
    expect(controller.state.adherence, 0.5);
  });

  test('refreshing asks both features for fresh data', () async {
    when(() => vitals.refresh()).thenAnswer((_) async => right(null));
    when(() => medications.getAdherence()).thenAnswer(
        (_) async => right(const MedicationAdherence(rate: 0, days: [])));

    await controller.fetchMetrics();

    verify(() => vitals.refresh()).called(1);
    verify(() => medications.getAdherence()).called(1);
  });
}
