import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/vitals/presentation/widgets/displays/blood_pressure_display.dart';

import '../../../helpers/pump_app.dart';

void main() {
  for (final code in ['en', 'tw', 'ee', 'ga']) {
    testWidgets('$code: fits the reading card without overflowing',
        (tester) async {
      await tester.pumpApp(
        const Center(
          child: SizedBox(
              width: 316,
              child: BloodPressureDisplay(systolic: '188', diastolic: '120')),
        ),
        locale: Locale(code),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('188'), findsOneWidget);
    });
  }
}
