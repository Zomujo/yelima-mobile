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
  late StreamController<void> newDays;
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
    newDays = StreamController<void>.broadcast();
    controller =
        MedicationController(repository: repo, newDays: newDays.stream);
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

  group('weekly adherence', () {
    final now = DateTime.now();
    MedicationAdherence saved(DateTime at) =>
        MedicationAdherence(rate: 37, days: const [], savedAt: at);

    test('a copy saved today shows before the server answers', () async {
      final server = Completer<Either<AppFailure, MedicationAdherence>>();
      when(() => repo.getCachedAdherence()).thenAnswer((_) async => saved(now));
      when(() => repo.getAdherence()).thenAnswer((_) => server.future);

      final done = controller.fetchAdherence();
      await pumpEventQueue();
      expect(controller.state.adherence?.rate, 37);

      server.complete(right(week));
      await done;
      expect(controller.state.adherence, week);
    });

    test('a copy from an earlier day waits for the server', () async {
      final server = Completer<Either<AppFailure, MedicationAdherence>>();
      when(() => repo.getCachedAdherence()).thenAnswer(
          (_) async => saved(now.subtract(const Duration(days: 2))));
      when(() => repo.getAdherence()).thenAnswer((_) => server.future);

      final done = controller.fetchAdherence();
      await pumpEventQueue();
      expect(controller.state.adherence, isNull);

      server.complete(right(week));
      await done;
      expect(controller.state.adherence, week);
    });

    test('if the server call fails, the older copy is shown', () async {
      final old = saved(now.subtract(const Duration(days: 2)));
      when(() => repo.getCachedAdherence()).thenAnswer((_) async => old);
      when(() => repo.getAdherence())
          .thenAnswer((_) async => left(const NetworkFailure()));

      await controller.fetchAdherence();

      expect(controller.state.adherence, old);
    });
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

  test('redraws when the next dose falls due, so Wait turns into Confirm',
      () async {
    final now = DateTime(2026, 10, 29, 2, 50, 59, 950);
    when(() => repo.watchSection(any())).thenAnswer((_) => Stream.value([
          dose(DateTime(2026, 10, 29, 2, 51)),
          dose(DateTime(2026, 10, 29, 1), taken: true),
        ]));
    withClock(Clock.fixed(now), controller.init);
    await pumpEventQueue();
    var redraws = 0;
    controller.addListener(() => redraws++);

    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(redraws, 1);
  });

  test('a new day reloads today\'s doses and the week', () async {
    controller.init();
    await pumpEventQueue();
    clearInteractions(repo);

    newDays.add(null);
    await pumpEventQueue();

    verify(() => repo.watchSection(any())).called(1);
    verify(() => repo.refreshAll()).called(1);
    verify(() => repo.getAdherence()).called(1);
  });

  test('a dose already taken is left alone', () async {
    await controller.confirm(dose(DateTime(2026, 10, 23, 8), taken: true));

    verifyNever(() => repo.confirmDose(any(), any()));
  });
}
