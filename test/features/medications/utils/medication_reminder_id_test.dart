import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/utils/medication_reminder_id.dart';

void main() {
  test('is the same on every run and every SDK (pinned value)', () {
    expect(medicationReminderId('665f00000000000000000001', 'MORNING'),
        1134428205);
  });

  test('differs per section and per medication', () {
    final ids = {
      for (final s in ['MORNING', 'AFTERNOON', 'EVENING', 'UNKNOWN'])
        medicationReminderId('m1', s),
      medicationReminderId('m2', 'MORNING'),
    };
    expect(ids, hasLength(5));
  });

  test('always fits a positive 31-bit Android notification id', () {
    for (var i = 0; i < 2000; i++) {
      final id = medicationReminderId('med-$i', 'EVENING');
      expect(id, inInclusiveRange(0, 0x7fffffff));
    }
  });
}
