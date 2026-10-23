import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/medications/data/models/create_medication_model.dart';
import 'package:yelima/features/medications/domain/entities/medication_entity.dart';
import 'package:yelima/features/medications/domain/entities/medicine_form_data.dart';
import 'package:yelima/features/medications/domain/repositories/medication_repository.dart';
import 'package:yelima/features/medications/domain/usecases/create_medication_usecase.dart';

class MockRepo extends Mock implements MedicationRepository {}

void main() {
  late MockRepo repo;
  late CreateMedicationUseCase useCase;

  const morning = DoseSchedule(hour: 8, minute: 0, period: 'AM', quantity: 1);
  MedicineFormData form(
          {String dosage = '5mg', DoseSchedule? dose = morning}) =>
      MedicineFormData(
          dosage: dosage, notes: '', unit: 'tablet', morning: dose);

  MedicationEntity existing(String name, String dosage) => MedicationEntity(
      id: 'm1',
      name: name,
      dosage: dosage,
      purpose: '',
      toBeTakenAt: DateTime(2026, 10, 23, 8),
      taken: false);

  setUpAll(() =>
      registerFallbackValue(const CreateMedicationModel(name: '', dosage: '')));

  setUp(() {
    repo = MockRepo();
    useCase = CreateMedicationUseCase(repo);
    when(() => repo.getAllMedications(pageSize: any(named: 'pageSize')))
        .thenAnswer((_) async => right(MedicationListResponse(
            rows: [existing('Metformin', '500mg')],
            total: 1,
            pageSize: 100,
            page: 1,
            totalPages: 1)));
    when(() => repo.createMedication(any()))
        .thenAnswer((_) async => right('local-1'));
  });

  test('MED-EC-44: a name or dosage of only spaces is refused', () async {
    expect((await useCase(form(), '   ')).isLeft(), isTrue);
    expect((await useCase(form(dosage: '  '), 'Amlodipine')).isLeft(), isTrue);
    verifyNever(() => repo.createMedication(any()));
  });

  test('saves the name and dosage trimmed', () async {
    await useCase(form(dosage: ' 5mg '), '  Amlodipine ');

    final model = verify(() => repo.createMedication(captureAny()))
        .captured
        .single as CreateMedicationModel;
    expect((model.name, model.dosage), ('Amlodipine', '5mg'));
  });

  test('a schedule is required', () async {
    expect((await useCase(form(dose: null), 'Amlodipine')).isLeft(), isTrue);
  });

  test('the same name and dosage, ignoring case and spaces, is a duplicate',
      () async {
    final result = await useCase(form(dosage: '500MG '), ' metformin');

    expect(result.getLeft().toNullable(), contains('already exists'));
  });

  test('asks for at most 100 rows (the server rejects more)', () async {
    await useCase(form(), 'Amlodipine');

    verify(() => repo.getAllMedications(pageSize: 100)).called(1);
  });
}
