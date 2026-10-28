import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/features/medications/domain/entities/medication_history_entity.dart';
import 'package:yelima/features/medications/presentation/widgets/medicine_details/adherence_calendar.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final now = DateTime(2026, 10, 26, 13);

  group('monthsSince', () {
    test('lists the start month up to now, newest first', () {
      expect(AdherenceCalendar.monthsSince(DateTime(2026, 8, 14), now),
          [DateTime(2026, 10), DateTime(2026, 9), DateTime(2026, 8)]);
    });

    test('a medicine added this month has only this month', () {
      expect(AdherenceCalendar.monthsSince(DateTime(2026, 10, 26), now),
          [DateTime(2026, 10)]);
    });

    test('crosses the new year', () {
      expect(
          AdherenceCalendar.monthsSince(
              DateTime(2025, 11, 3), DateTime(2026, 2, 1)),
          [
            DateTime(2026, 2),
            DateTime(2026, 1),
            DateTime(2025, 12),
            DateTime(2025, 11),
          ]);
    });

    test('an unknown start shows the last 6 months', () {
      final months = AdherenceCalendar.monthsSince(null, now);
      expect(months.first, DateTime(2026, 10));
      expect(months.last, DateTime(2026, 5));
      expect(months, hasLength(6));
    });
  });

  /// The colour behind day [day] of the shown month.
  Color? dayColor(WidgetTester tester, int day) {
    final box = tester.widget<Container>(find
        .ancestor(of: find.text('$day'), matching: find.byType(Container))
        .first);
    return (box.decoration as BoxDecoration).color;
  }

  // The server sends "not taken" for every day of the month, even before the start.
  final history = MedicationHistoryEntity(
    medicationName: 'Metformin',
    adherenceRate: 0,
    logs: [
      for (var d = 1; d <= 25; d++)
        MedicationLogEntity(
            id: '$d', taken: false, takenAt: DateTime(2026, 10, d)),
    ],
  );

  testWidgets('days before the start are blank, not missed', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await tester.pumpApp(SingleChildScrollView(
        child: AdherenceCalendar(
          history: history,
          startDate: DateTime.utc(2026, 10, 20, 13, 10),
          onMonthChanged: (_) {},
        ),
      ));

      expect(dayColor(tester, 19), Colors.transparent);
      expect(dayColor(tester, 21), AppColors.slate300);
    });
  });

  testWidgets('a single month has no dropdown', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await tester.pumpApp(SingleChildScrollView(
        child: AdherenceCalendar(
          history: history,
          startDate: DateTime(2026, 10, 26),
          onMonthChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
      await tester.tap(find.text('October 2026'));
      await tester.pumpAndSettle();
      expect(find.text('September 2026'), findsNothing);
    });
  });

  testWidgets('without a start date every past day keeps its status',
      (tester) async {
    await withClock(Clock.fixed(now), () async {
      await tester.pumpApp(SingleChildScrollView(
        child: AdherenceCalendar(history: history, onMonthChanged: (_) {}),
      ));

      expect(dayColor(tester, 5), AppColors.slate300);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });
  });

  testWidgets('no settled day yet shows no percentage, not 0 %',
      (tester) async {
    await withClock(Clock.fixed(now), () async {
      await tester.pumpApp(SingleChildScrollView(
        child: AdherenceCalendar(
          history: MedicationHistoryEntity(
            medicationName: 'Metformin',
            adherenceRate: 0,
            logs: [
              MedicationLogEntity(
                  id: '1', taken: null, takenAt: DateTime(2026, 10, 26)),
            ],
          ),
          onMonthChanged: (_) {},
        ),
      ));

      expect(find.text('0%'), findsNothing);
    });
  });
}
