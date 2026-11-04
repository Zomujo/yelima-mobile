import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/medications/domain/entities/medication_form.dart';
import 'package:yelima/features/medications/domain/entities/medication_section.dart';
import 'package:yelima/features/medications/domain/medication_failures.dart';
import 'package:yelima/features/medications/domain/models/dosing_schedule_model.dart';
import 'package:yelima/features/medications/domain/models/medication_detail_model.dart';
import 'package:yelima/features/medications/domain/repositories/medication_repository.dart';
import 'package:yelima/features/medications/medications_providers.dart';
import 'package:yelima/features/medications/presentation/controllers/add_medication_form_controller.dart';
import 'package:yelima/features/medications/presentation/states/medication_form_state.dart';

class MockRepo extends Mock implements MedicationRepository {}

void main() {
  late MockRepo repo;
  late ProviderContainer container;
  late AddMedicationFormController form;
  MedicationFormState fields() =>
      container.read(addMedicationFormControllerProvider).form;

  setUpAll(
      () => registerFallbackValue(const MedicationForm(name: '', dosage: '')));

  setUp(() {
    repo = MockRepo();
    container = ProviderContainer(
        overrides: [medicationRepositoryProvider.overrideWithValue(repo)]);
    // Screen-local: kept alive by a listener, as the screen would.
    container.listen(addMedicationFormControllerProvider, (_, __) {});
    form = container.read(addMedicationFormControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('only switched-on sections become doses, on the 24-hour clock', () {
    form
      ..nameController.text = 'Amlodipine'
      ..dosageController.text = '5mg'
      ..setSlot(MedicationSection.evening,
          enabled: true, time: const TimeOfDay(hour: 21, minute: 15))
      ..setSlot(MedicationSection.morning, quantity: 3);

    expect(form.form.doses, {
      MedicationSection.evening:
          const DoseSchedule(hour: 21, minute: 15, quantity: 1),
    });
    expect(fields().hasChanges, isTrue);
  });

  test('loading saved details fills the fields without counting as a change',
      () {
    form.load(MedicationDetailModel(
      id: 'm1',
      name: 'Amlodipine',
      dosage: '5mg',
      notes: 'after food',
      evening: const DosingScheduleModel(
        time: ScheduleTimeModel(hour: 9, minutes: 30, timeDesignators: 'PM'),
        quantity: ScheduleQuantityModel(value: 2, unit: 'capsule'),
      ),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ));

    final evening = fields().slots[MedicationSection.evening]!;
    expect((evening.enabled, evening.time, evening.quantity),
        (true, const TimeOfDay(hour: 21, minute: 30), 2));
    expect(fields().slots[MedicationSection.morning]!.enabled, isFalse);
    expect(fields().unit, 'capsule');
    expect(fields().hasChanges, isFalse);
  });

  test('a failed save reports why and stays changed', () async {
    when(() => repo.createMedication(any()))
        .thenAnswer((_) async => left(const MissingScheduleFailure()));
    form.markChanged();

    expect(await form.persist(), const MissingScheduleFailure());
    expect(fields().hasChanges, isTrue);
  });
}
