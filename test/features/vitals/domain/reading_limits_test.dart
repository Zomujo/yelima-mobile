import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/vitals/domain/reading_limits.dart';

void main() {
  test('accepts a normal reading', () {
    expect(ReadingLimits.bloodPressureError(120, 80), isNull);
    expect(ReadingLimits.bloodSugarError(5.5), isNull);
  });

  test('refuses systolic at or below diastolic', () {
    expect(ReadingLimits.bloodPressureError(80, 80),
        ReadingError.systolicNotAboveDiastolic);
    expect(ReadingLimits.bloodPressureError(70, 90),
        ReadingError.systolicNotAboveDiastolic);
  });

  test('refuses values outside the picker ranges', () {
    expect(ReadingLimits.bloodPressureError(59, 40), ReadingError.bpOutOfRange);
    expect(
        ReadingLimits.bloodPressureError(251, 100), ReadingError.bpOutOfRange);
    expect(
        ReadingLimits.bloodPressureError(120, 39), ReadingError.bpOutOfRange);
    expect(ReadingLimits.bloodSugarError(0.9), ReadingError.sugarOutOfRange);
    expect(ReadingLimits.bloodSugarError(33.4), ReadingError.sugarOutOfRange);
  });
}
