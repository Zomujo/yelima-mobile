import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/presentation/widgets/medications_dashboard/medication_card.dart';

import '../../../../helpers/pump_app.dart';

MedicationCard _card({required bool isTaken}) => MedicationCard(
    name: 'Metformin',
    dosage: '500mg',
    purpose: '',
    time: '8:00 AM',
    isTaken: isTaken,
    onConfirm: () {});

void main() {
  testWidgets('confirming turns the button into a tick', (tester) async {
    var taken = false;
    late StateSetter rebuild;
    await tester.pumpApp(StatefulBuilder(builder: (context, setState) {
      rebuild = setState;
      return _card(isTaken: taken);
    }));
    await tester.pumpAndSettle();
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);

    rebuild(() => taken = true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.check), findsOneWidget, reason: 'fading in');

    await tester.pumpAndSettle();
    expect(find.text('Confirm'), findsNothing);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
