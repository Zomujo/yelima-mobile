import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/domain/entities/medication_history_entity.dart';

void main() {
  test('the calendar only shows the selected month\'s doses', () {
    final history = MedicationHistoryEntity(
      medicationName: 'Amlodipine',
      adherenceRate: 50,
      logs: [
        MedicationLogEntity(
            id: 'a', taken: true, takenAt: DateTime(2026, 10, 3)),
        MedicationLogEntity(
            id: 'b', taken: false, takenAt: DateTime(2026, 9, 3)),
        MedicationLogEntity(
            id: 'c', taken: false, takenAt: DateTime(2026, 10, 12)),
      ],
    );

    expect(history.takenByDay(DateTime(2026, 10)), {3: true, 12: false});
    expect(history.takenByDay(DateTime(2026, 9)), {3: false});
  });
}
