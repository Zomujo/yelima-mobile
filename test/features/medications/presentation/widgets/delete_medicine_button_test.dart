import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/medications/domain/models/medication_detail_model.dart';
import 'package:yelima/features/medications/domain/repositories/medication_repository.dart';
import 'package:yelima/features/medications/presentation/controllers/medicine_details_form_controller.dart';
import 'package:yelima/features/medications/presentation/widgets/medicine_details/delete_medicine_button.dart';

import '../../../../helpers/pump_app.dart';

class MockRepo extends Mock implements MedicationRepository {}

void main() {
  late MockRepo repo;
  late MedicineDetailsFormController controller;

  setUp(() {
    repo = MockRepo();
    when(() => repo.onIdChanged).thenAnswer((_) => const Stream.empty());
    when(() => repo.deleteMedication('m1'))
        .thenAnswer((_) async => right(null));
    controller =
        MedicineDetailsFormController(repository: repo, medicationId: 'm1')
          ..detail = MedicationDetailModel(
              id: 'm1',
              name: 'Metformin',
              dosage: '500mg',
              createdAt: DateTime(2026, 10, 26),
              updatedAt: DateTime(2026, 10, 26));
  });

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.pumpApp(DeleteMedicineButton(controller: controller));
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
