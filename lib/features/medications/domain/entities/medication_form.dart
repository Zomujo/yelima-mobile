import 'package:equatable/equatable.dart';

import '../../../../core/failures/app_failure.dart';
import '../medication_failures.dart';
import 'medication_section.dart';

/// One dose: a time of day (24-hour clock) and how many units.
class DoseSchedule extends Equatable {
  const DoseSchedule(
      {required this.hour, required this.minute, required this.quantity});

  final int hour;
  final int minute;
  final int quantity;

  @override
  List<Object?> get props => [hour, minute, quantity];
}

/// What the user entered to add or edit a medication.
class MedicationForm {
  const MedicationForm({
    required this.name,
    required this.dosage,
    this.notes = '',
    this.unit = 'tablet',
    this.doses = const {},
  });

  final String name;
  final String dosage;
  final String notes;
  final String unit;
  final Map<MedicationSection, DoseSchedule> doses;

  /// The first problem that stops saving, or null.
  AppFailure? get problem {
    if (name.trim().isEmpty || dosage.trim().isEmpty) {
      return const MissingNameOrDosageFailure();
    }
    if (doses.isEmpty) return const MissingScheduleFailure();
    return null;
  }
}
