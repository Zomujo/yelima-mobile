import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/features/medications/domain/entities/medication_history_entity.dart';
import 'package:yelima/features/medications/domain/models/medication_detail_model.dart';
import 'package:yelima/features/medications/domain/repositories/medication_repository.dart';
import 'package:yelima/features/medications/medications_providers.dart';
import 'package:yelima/features/medications/presentation/controllers/medicine_details_form_controller.dart';
import 'package:yelima/features/medications/presentation/states/medication_form_state.dart';

class MockRepo extends Mock implements MedicationRepository {}

void main() {
  late MockRepo repo;
  late Completer<Either<AppFailure, MedicationDetailModel>> server;
  late Completer<Either<AppFailure, MedicationHistoryEntity>> serverHistory;
  late ProviderContainer container;
  final details = medicineDetailsFormControllerProvider('m1');
  MedicineDetailsState state() => container.read(details);

  /// Opens the screen's controller, which starts loading at once.
  void open() => container.listen(details, (_, __) {});

  MedicationDetailModel detail(String dosage) => MedicationDetailModel(
      id: 'm1',
      name: 'Metformin',
      dosage: dosage,
      createdAt: DateTime(2026, 10, 26),
      updatedAt: DateTime(2026, 10, 26));
  MedicationHistoryEntity history(int rate) => MedicationHistoryEntity(
      medicationName: 'Metformin', adherenceRate: rate, logs: const []);

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    repo = MockRepo();
    server = Completer();
    serverHistory = Completer();
    when(() => repo.onIdChanged).thenAnswer((_) => const Stream.empty());
    when(() => repo.getCachedMedication('m1'))
        .thenAnswer((_) async => detail('500mg'));
    when(() => repo.getMedicationById('m1')).thenAnswer((_) => server.future);
    when(() => repo.getCachedHistory('m1', any()))
        .thenAnswer((_) async => history(50));
    when(() => repo.getMedicationHistory('m1', any()))
        .thenAnswer((_) => serverHistory.future);
    container = ProviderContainer(
        overrides: [medicationRepositoryProvider.overrideWithValue(repo)]);
  });

  tearDown(() => container.dispose());

  test('shows the phone\'s copy before the server answers, then updates',
      () async {
    open();
    await pumpEventQueue();

    expect(state().isLoading, isFalse);
    expect(state().name, 'Metformin');
    expect(state().history?.adherenceRate, 50);

    server.complete(right(detail('850mg')));
    serverHistory.complete(right(history(75)));
    await pumpEventQueue();

    expect(state().detail?.dosage, '850mg');
    expect(state().history?.adherenceRate, 75);
  });

  test('a failed refresh keeps the phone\'s copy without an error', () async {
    server.complete(left(const NetworkFailure()));
    serverHistory.complete(left(const NetworkFailure()));

    open();
    await pumpEventQueue();

    expect(state().detail?.dosage, '500mg');
    expect(state().error, isNull);
  });
}
