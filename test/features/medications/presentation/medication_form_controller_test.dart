import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/medications/domain/entities/medication_form.dart';
import 'package:yelima/features/medications/domain/entities/medication_section.dart';
import 'package:yelima/features/medications/domain/medication_failures.dart';
import 'package:yelima/features/medications/domain/models/dosing_schedule_model.dart';
import 'package:yelima/features/medications/domain/models/medication_detail_model.dart';
import 'package:yelima/features/medications/domain/repositories/medication_repository.dart';
import 'package:yelima/features/medications/presentation/controllers/add_medication_form_controller.dart';

class MockRepo extends Mock implements MedicationRepository {}

void main() {
  late MockRepo repo;
  late AddMedicationFormController form;

  setUpAll(
      () => registerFallbackValue(const MedicationForm(name: '', dosage: '')));

  setUp(() {
    repo = MockRepo();
    form = AddMedicationFormController(repository: repo);
  });

  tearDown(() => form.dispose());

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
    expect(form.hasChanges, isTrue);
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

    final evening = form.slots[MedicationSection.evening]!;
    expect((evening.enabled, evening.time, evening.quantity),
        (true, const TimeOfDay(hour: 21, minute: 30), 2));
    expect(form.slots[MedicationSection.morning]!.enabled, isFalse);
    expect(form.unit, 'capsule');
    expect(form.hasChanges, isFalse);
  });

  test('a failed save reports why and stays changed', () async {
    when(() => repo.createMedication(any()))
        .thenAnswer((_) async => left(const MissingScheduleFailure()));
    form.markChanged();

    expect(await form.persist(), const MissingScheduleFailure());
    expect(form.hasChanges, isTrue);
  });
}
