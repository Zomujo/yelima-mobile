import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/vitals/domain/entities/reading_form.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/reading_limits.dart';

void main() {
  final at = DateTime(2026, 10, 23, 8);

  ReadingForm bp(int sys, int dia) => ReadingForm(
      kind: VitalKind.bloodPressure,
      systolic: sys,
      diastolic: dia,
      sugarLevel: 0,
      recordedAt: at);

  ReadingForm sugar(double level, [String subType = 'fasting']) => ReadingForm(
      kind: VitalKind.bloodSugar,
      subType: subType,
      systolic: 0,
      diastolic: 0,
      sugarLevel: level,
      recordedAt: at);

  test('a BP reading gets the server\'s grade and shape', () {
    final v = bp(185, 125).toReading('id');

    expect((v.vitalType, v.value, v.unit, v.severity),
        ('bloodPressure', '185/125', 'mmHg', 'hypertensive_crisis'));
    expect(v.recordedAt, at);
  });

  test('low blood pressure is graded (it used to show as good)', () {
    expect(bp(85, 55).toReading('id').severity, 'hypotensive');
  });

  test('a sugar reading is in mmol/L with the server\'s grade', () {
    final v = sugar(5.25).toReading('id');

    expect((v.vitalType, v.value, v.unit, v.vitalSubType, v.severity),
        ('bloodSugar', '5.3', 'mmol/L', 'fasting', 'normal'));
  });

  test('post-meal 13.9 and above is critically high, like fasting', () {
    expect(sugar(15.0, 'postprandial').toReading('id').severity,
        'critically_high');
    expect(sugar(15.0).toReading('id').severity, 'critically_high');
  });

  group('problems', () {
    test('VIT-EC-11: systolic must be above diastolic', () {
      expect(bp(90, 120).problem, ReadingError.systolicNotAboveDiastolic);
      expect(bp(100, 100).problem, ReadingError.systolicNotAboveDiastolic);
    });

    test('VIT-EC-12: out-of-range blood pressure is refused', () {
      expect(bp(300, 20).problem, ReadingError.bpOutOfRange);
    });

    test('VIT-EC-13: a mg/dL number is not saved as mmol/L', () {
      expect(sugar(126).problem, ReadingError.sugarOutOfRange);
    });

    test('values at the limits are accepted', () {
      expect(bp(250, 150).problem, isNull);
      expect(sugar(1.0).problem, isNull);
    });
  });

  group('LatestVitals', () {
    VitalHistoryEntity reading(String type, String value, [DateTime? when]) =>
        VitalHistoryEntity(
            id: value,
            vitalType: type,
            value: value,
            unit: '',
            severity: 'normal',
            vitalName: '',
            recordedAt: when);

    test('VIT-EC-08: the newest reading wins, whatever the row order', () {
      final latest = LatestVitals.from([
        reading('bloodPressure', '120/80', DateTime(2026, 10, 20)),
        reading('bloodPressure', '185/125', DateTime(2026, 10, 23)),
        reading('bloodGlucose', '5.1', DateTime(2026, 10, 1)),
        reading('bloodSugar', '9.0', DateTime(2026, 10, 22)),
      ]);

      expect(latest.systolicDiastolic, (185, 125));
      expect(latest.sugarLevel, 9.0);
    });

    test('undated server rows keep the server\'s newest-first order', () {
      final latest = LatestVitals.from([
        reading('bloodPressure', '130/85'),
        reading('bloodPressure', '120/80'),
      ]);

      expect(latest.bloodPressure?.value, '130/85');
    });

    test('a dated local reading beats undated server rows', () {
      final latest = LatestVitals.from([
        reading('bloodPressure', '120/80'),
        reading('bloodPressure', '150/95', DateTime(2026, 10, 23)),
      ]);

      expect(latest.bloodPressure?.value, '150/95');
    });

    test('nothing saved gives no values', () {
      final latest = LatestVitals.from(const []);
      expect((latest.systolicDiastolic, latest.sugarLevel), (null, null));
    });
  });
}
