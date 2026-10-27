import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/domain/models/medication_detail_model.dart';

void main() {
  final json = {
    'id': 'm1',
    'name': 'Metformin',
    'dosage': '500mg',
    'createdAt': '2026-10-26T13:06:59.020Z',
    'updatedAt': '2026-10-26T13:06:59.020Z',
  };

  test('reads the start date the server sends', () {
    final model = MedicationDetailModel.fromJson(
        {...json, 'startDate': '2026-10-26T13:10:00.000Z'});
    expect(model.startDate, DateTime.utc(2026, 10, 26, 13, 10));
  });

  test('a missing start date is null', () {
    expect(MedicationDetailModel.fromJson(json).startDate, isNull);
  });
}
