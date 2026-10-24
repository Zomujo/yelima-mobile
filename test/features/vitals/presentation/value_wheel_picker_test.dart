import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/vitals/presentation/widgets/pickers/value_wheel_picker_bottom_sheet.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> open(
      WidgetTester tester, void Function(BuildContext) show) async {
    await tester.pumpApp(Builder(
      builder: (context) =>
          TextButton(onPressed: () => show(context), child: const Text('open')),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('confirming unchanged wheels returns the starting reading',
      (tester) async {
    (int, int)? picked;
    await open(
        tester,
        (context) => ValueWheelPickerBottomSheet.showDual(context,
            title: 'BP',
            initialValue1: 120,
            initialValue2: 80,
            minValue1: 60,
            maxValue1: 250,
            minValue2: 40,
            maxValue2: 150,
            onChanged: (a, b) => picked = (a, b)));

    expect(find.byType(CupertinoPicker), findsNWidgets(2));
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(picked, (120, 80));
  });

  testWidgets('the single wheel steps by 0.1 without drifting', (tester) async {
    double? picked;
    await open(
        tester,
        (context) => ValueWheelPickerBottomSheet.showSingle(context,
            title: 'Sugar',
            initialValue: 5.5,
            minValue: 1.0,
            maxValue: 30.0,
            onChanged: (v) => picked = v));

    expect(find.text('5.5'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(picked, 5.5);
  });
}
