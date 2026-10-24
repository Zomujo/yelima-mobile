import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/domain/entities/medication_adherence.dart';
import 'package:yelima/features/medications/presentation/widgets/medications_dashboard/adherence_card.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'done days show a tick, missed days a cross, open days their dose count',
      (tester) async {
    await withClock(Clock.fixed(DateTime(2026, 10, 23, 12)), () async {
      await tester.pumpApp(AdherenceCard(
        adherence: MedicationAdherence(rate: 80, days: [
          AdherenceDay(taken: true, takenAt: DateTime(2026, 10, 19)),
          AdherenceDay(
              taken: false,
              takenAt: DateTime(2026, 10, 20),
              takenDoses: 1,
              scheduledDoses: 2),
          AdherenceDay(
              taken: null,
              takenAt: DateTime(2026, 10, 22),
              takenDoses: 1,
              scheduledDoses: 2),
          AdherenceDay(taken: null, takenAt: DateTime(2026, 10, 25)),
        ]),
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
    });
  });

  testWidgets('a day with no doses scheduled is not a miss', (tester) async {
    await tester.pumpApp(AdherenceCard(
      adherence: MedicationAdherence(rate: 0, days: [
        AdherenceDay(
            taken: false,
            takenAt: DateTime(2026, 10, 19),
            takenDoses: 0,
            scheduledDoses: 0),
      ]),
    ));

    expect(find.byIcon(Icons.close), findsNothing);
  });
}
