/// A framework-agnostic domain entity representing one dosing schedule slot.
class DoseSchedule {
  final int hour;
  final int minute;
  final String period; // 'AM' | 'PM'
  final int quantity;

  const DoseSchedule({
    required this.hour,
    required this.minute,
    required this.period,
    required this.quantity,
  });
}

/// Holds the validated, framework-agnostic form data for updating a medication.
class MedicineFormData {
  final String dosage;
  final String notes;
  final String unit;
  final DoseSchedule? morning;
  final DoseSchedule? afternoon;
  final DoseSchedule? evening;

  const MedicineFormData({
    required this.dosage,
    required this.notes,
    required this.unit,
    this.morning,
    this.afternoon,
    this.evening,
  });
}
