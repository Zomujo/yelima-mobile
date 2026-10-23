import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/appointment/data/models/appointment_model.dart';

void main() {
  test('cancelled appointments are left out of a page', () {
    final page = AppointmentListResponseModel.fromJson(const {
      'data': {
        'rows': [
          {'id': 'a1', 'status': 'scheduled'},
          {'id': 'a2', 'status': 'cancelled'},
          {'id': 'a3', 'status': 'rescheduled'},
        ],
      },
    });

    expect(page.rows.map((a) => a.id), ['a1', 'a3']);
  });
}
