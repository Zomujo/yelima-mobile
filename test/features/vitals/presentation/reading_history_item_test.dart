import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/presentation/widgets/history/reading_history_item.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<Color?> labelColor(WidgetTester tester, VitalSeverity grade) async {
    await tester.pumpApp(ReadingHistoryItem(
        date: 'Monday 26 October • 1:00 PM',
        vitalName: 'Sugar',
        vitalValue: '1.0 mmol/L',
        severity: grade));
    final dot = tester.widget<Container>(find.byWidgetPredicate((w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).shape == BoxShape.circle));
    return (dot.decoration as BoxDecoration).color;
  }

  testWidgets('critically low is as red as critical', (tester) async {
    final low = await labelColor(tester, VitalSeverity.criticallyLow);
    final high = await labelColor(tester, VitalSeverity.critical);
    expect(low, high);
    expect(low, Colors.red.shade700);
  });
}
