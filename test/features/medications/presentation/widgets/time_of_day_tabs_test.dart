import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/domain/entities/medication_section.dart';
import 'package:yelima/features/medications/presentation/widgets/medications_dashboard/time_of_day_tabs.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('the underline slides under the newly selected tab',
      (tester) async {
    var selected = MedicationSection.morning;
    await tester.pumpApp(StatefulBuilder(
      builder: (context, setState) => TimeOfDayTabs(
        selected: selected,
        counts: null,
        onSelected: (s) => setState(() => selected = s),
      ),
    ));
    await tester.pumpAndSettle();
    double lineLeft() => tester
        .getTopLeft(find.descendant(
            of: find.byType(AnimatedPositioned),
            matching: find.byType(ColoredBox)))
        .dx;
    expect(lineLeft(), tester.getTopLeft(find.text('MORNING')).dx);

    await tester.tap(find.text('EVENING'));
    await tester.pumpAndSettle();
    expect(lineLeft(), tester.getTopLeft(find.text('EVENING')).dx);
  });
}
