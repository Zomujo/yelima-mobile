import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/progress/domain/entities/vital_trends.dart';
import 'package:yelima/features/progress/presentation/widgets/graphs/glucose_graph.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'a very low sugar never pushes the axis below 0, lines stay straight',
      (tester) async {
    await tester.pumpApp(GlucoseGraph(
      data: VitalTrend(labels: [
        DateTime(2026, 10, 26, 11).toIso8601String(),
        DateTime(2026, 10, 26, 13).toIso8601String(),
      ], values: const [
        5.4,
        1.0
      ]),
    ));

    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    expect(data.minY, greaterThanOrEqualTo(0));
    expect(data.lineBarsData.first.isCurved, isFalse);
  });
}
