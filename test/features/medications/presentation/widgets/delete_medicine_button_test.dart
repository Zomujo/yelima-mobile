import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/features/medications/domain/entities/medication_history_entity.dart';
import 'package:yelima/features/medications/domain/models/medication_detail_model.dart';
import 'package:yelima/features/medications/domain/repositories/medication_repository.dart';
import 'package:yelima/features/medications/medications_providers.dart';
import 'package:yelima/features/medications/presentation/widgets/medicine_details/delete_medicine_button.dart';

import '../../../../helpers/pump_app.dart';

class MockRepo extends Mock implements MedicationRepository {}

void main() {
  late MockRepo repo;

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    repo = MockRepo();
    when(() => repo.onIdChanged).thenAnswer((_) => const Stream.empty());
    when(() => repo.deleteMedication('m1'))
        .thenAnswer((_) async => right(null));
    final metformin = MedicationDetailModel(
        id: 'm1',
        name: 'Metformin',
        dosage: '500mg',
        createdAt: DateTime(2026, 10, 26),
        updatedAt: DateTime(2026, 10, 26));
    when(() => repo.getCachedMedication('m1'))
        .thenAnswer((_) async => metformin);
    when(() => repo.getMedicationById('m1'))
        .thenAnswer((_) async => right(metformin));
    when(() => repo.getCachedHistory('m1', any())).thenAnswer((_) async =>
        const MedicationHistoryEntity(
            medicationName: 'Metformin', adherenceRate: 0, logs: []));
    when(() => repo.getMedicationHistory('m1', any()))
        .thenAnswer((_) async => left(const NetworkFailure()));
  });

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.pumpApp(const DeleteMedicineButton(medicationId: 'm1'),
        overrides: [medicationRepositoryProvider.overrideWithValue(repo)]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Medication'));
    await tester.pumpAndSettle();
  }

  testWidgets('asks, then deletes', (tester) async {
    await tapDelete(tester);
    expect(find.text('Are you sure you want to delete Metformin?'),
        findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verify(() => repo.deleteMedication('m1')).called(1);
  });

  testWidgets('cancel keeps the medicine', (tester) async {
    await tapDelete(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => repo.deleteMedication(any()));
  });
}
