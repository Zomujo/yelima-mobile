import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/features/medications/domain/entities/medication_adherence.dart';
import 'package:yelima/features/medications/domain/entities/medication_count.dart';
import 'package:yelima/features/medications/domain/entities/medication_entity.dart';
import 'package:yelima/features/medications/domain/entities/medication_section.dart';
import 'package:yelima/features/medications/domain/medication_failures.dart';
import 'package:yelima/features/medications/domain/repositories/medication_repository.dart';
import 'package:yelima/features/medications/presentation/controllers/medication_controller.dart';

class MockRepo extends Mock implements MedicationRepository {}

void main() {
  late MockRepo repo;
  late MedicationController controller;
  const week = MedicationAdherence(rate: 50, days: []);

  MedicationEntity dose(DateTime at, {bool taken = false}) => MedicationEntity(
      id: 'm1',
      name: 'Amlodipine',
      dosage: '5mg',
      purpose: '',
      toBeTakenAt: at,
      taken: taken);

  setUpAll(() => registerFallbackValue(MedicationSection.morning));

  setUp(() {
    repo = MockRepo();
    when(() => repo.onSynced).thenAnswer((_) => const Stream.empty());
    when(() => repo.watchCounts()).thenAnswer((_) => Stream.value(
        const MedicationCount(morning: 1, afternoon: 0, evening: 2)));
    when(() => repo.watchSection(any()))
        .thenAnswer((_) => Stream.value(const []));
    when(() => repo.getCachedAdherence()).thenAnswer((_) async => week);
    when(() => repo.getAdherence()).thenAnswer((_) async => right(week));
    when(() => repo.refreshAll()).thenAnswer((_) async {});
    when(() => repo.confirmDose(any(), any()))
        .thenAnswer((_) async => right(null));
    controller = MedicationController(repository: repo);
  });

  tearDown(() => controller.dispose());

  test('opens on the section for the time of day', () async {
    withClock(Clock.fixed(DateTime(2026, 10, 23, 18)), controller.init);
    await pumpEventQueue();

    expect(controller.state.section, MedicationSection.evening);
    expect(controller.state.counts?.evening, 2);
    expect(controller.state.adherence, week);
    verify(() => repo.refreshAll()).called(1);
  });

  test('a dose tapped before its time is refused without saving', () async {
    final result = await withClock(Clock.fixed(DateTime(2026, 10, 23, 7, 59)),
        () => controller.confirm(dose(DateTime(2026, 10, 23, 8))));

    expect(result, left<AppFailure, void>(const DoseNotDueFailure()));
    verifyNever(() => repo.confirmDose(any(), any()));
  });

  test('a due dose is confirmed for the shown section', () async {
    final result = await withClock(Clock.fixed(DateTime(2026, 10, 23, 8, 5)),
        () => controller.confirm(dose(DateTime(2026, 10, 23, 8))));

    expect(result.isRight(), isTrue);
    verify(() => repo.confirmDose('m1', MedicationSection.morning)).called(1);
  });

  test('a dose already taken is left alone', () async {
    await controller.confirm(dose(DateTime(2026, 10, 23, 8), taken: true));

    verifyNever(() => repo.confirmDose(any(), any()));
  });
}
