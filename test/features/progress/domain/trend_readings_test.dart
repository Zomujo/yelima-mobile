import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/progress/domain/entities/vital_trends.dart';

void main() {
  final since = DateTime.utc(2026, 10, 26);

  // The server's week on 2 Nov, before the 122/76 reading reached it.
  const serverBP = BPTrend(
    labels: ['2026-10-26T11:46:56.000Z', '2026-10-26T12:57:18.542Z'],
    systolic: [120, 211],
    diastolic: [80, 131],
  );

  test('a reading saved on the phone is added and becomes the latest', () {
    final trend = serverBP
        .withReadings([(DateTime.utc(2026, 11, 2, 14, 58), '122/76')], since);

    expect(trend.systolic, [120, 211, 122]);
    expect(trend.diastolic, [80, 131, 76]);
    expect(trend.labels.last, '2026-11-02T14:58:00.000Z');
  });

  test('a reading the server already has is not drawn twice', () {
    // The phone keeps microseconds; the server sends milliseconds.
    final trend = serverBP.withReadings(
        [(DateTime.utc(2026, 10, 26, 12, 57, 18, 542, 251), '211/131')], since);

    expect(trend.systolic, [120, 211]);
  });

  test('readings from before the chart\'s range are left out', () {
    final trend = serverBP
        .withReadings([(DateTime.utc(2026, 10, 20, 9), '150/95')], since);

    expect(trend.systolic, [120, 211]);
  });

  test('sugar: the newest phone reading replaces the server\'s latest', () {
    const serverSugar = VitalTrend(
        labels: ['2026-10-28T18:11:48.459Z'], values: [1.6], latestValue: 1.6);

    final trend = serverSugar
        .withReadings([(DateTime.utc(2026, 11, 2, 15, 6), '5.9')], since);

    expect(trend.values, [1.6, 5.9]);
    expect(trend.latestValue, 5.9);
  });

  test('with no phone readings the trend is unchanged', () {
    expect(serverBP.withReadings(const [], since), serverBP);
  });

  group('where a chart starts, like the server', () {
    final now = DateTime(2026, 11, 3, 9, 30);

    test('24 Hours starts at midnight yesterday', () {
      expect(ChartDateRange.today.since(now), DateTime(2026, 11, 2));
    });

    test('1 Week starts at midnight 7 days ago', () {
      expect(ChartDateRange.thisWeek.since(now), DateTime(2026, 10, 27));
    });

    test('1 Month starts at midnight a month ago, clamped to the month end',
        () {
      expect(ChartDateRange.thisMonth.since(now), DateTime(2026, 10, 3));
      expect(ChartDateRange.thisMonth.since(DateTime(2027, 3, 31, 8)),
          DateTime(2027, 2, 28));
    });
  });
}
