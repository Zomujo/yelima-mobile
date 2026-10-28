import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/progress/domain/entities/vital_trends.dart';
import 'package:yelima/features/progress/presentation/widgets/graphs/nice_step.dart';

void main() {
  VitalTrend trend(List<DateTime> at) => VitalTrend(
      labels: [for (final d in at) d.toIso8601String()],
      values: [for (final _ in at) 5.0]);

  test('a day or less shows times', () {
    expect(
        trend([DateTime(2026, 10, 26, 11, 47), DateTime(2026, 10, 26, 12, 57)])
            .formattedLabels,
        ['11:47', '12:57']);
  });

  test('a longer span shows each day once', () {
    expect(
        trend([
          DateTime(2026, 10, 20, 9),
          DateTime(2026, 10, 26, 11),
          DateTime(2026, 10, 26, 12),
          DateTime(2026, 10, 26, 13),
        ]).formattedLabels,
        ['20', '26', '', '']);
  });

  test('grid steps are round numbers', () {
    expect(niceStep(37), 50);
    expect(niceStep(12), 20);
    expect(niceStep(0.8), 1);
    expect(niceStep(2.4), 5);
    expect(niceStep(0), 1);
  });
}
