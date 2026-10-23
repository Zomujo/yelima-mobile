import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/constants/app_images.dart';
import 'package:yelima/features/appointment/domain/entities/appointment_entity.dart';
import 'package:yelima/features/appointment/presentation/widgets/appointment_card.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final now = DateTime(2026, 10, 23, 9, 0);

  AppointmentEntity appointmentOn(DateTime date) => AppointmentEntity(
        id: 'a1',
        title: 'Blood pressure review',
        appointmentDate: date,
        hostPersonnel: const HostPersonnelEntity(
          id: 'p1',
          userName: 'Dr Mensah',
          facility: FacilityEntity(name: 'Korle Bu'),
        ),
      );

  Future<void> pumpCard(WidgetTester tester, DateTime date,
      {bool isPast = false}) async {
    await withClock(Clock.fixed(now), () async {
      await tester.pumpApp(AppointmentCard(
        appointment: appointmentOn(date),
        iconAsset: AppImages.calendarIcon.assetName,
        isPast: isPast,
      ));
    });
  }

  testWidgets('shows date, title, clinician and facility', (tester) async {
    await pumpCard(tester, DateTime(2026, 10, 24, 14, 30));

    expect(find.text('Sat 24 Oct • 14:30'), findsOneWidget);
    expect(find.text('Blood pressure review'), findsOneWidget);
    expect(find.text('with Dr Mensah • Korle Bu'), findsOneWidget);
  });

  group('upcoming label', () {
    const cases = <(int, String)>[
      (0, 'today'),
      (1, 'tomorrow'),
      (3, 'in 3 days'),
      (8, 'in 1 week'),
      (21, 'in 3 weeks'),
      (65, 'in 2 months'),
    ];
    for (final (days, label) in cases) {
      testWidgets('$days days ahead -> "$label"', (tester) async {
        await pumpCard(tester, now.add(Duration(days: days)));
        expect(find.text(label), findsOneWidget);
      });
    }
  });

  group('past label', () {
    const cases = <(int, String)>[
      (1, 'yesterday'),
      (4, '4 days ago'),
      (10, '1 week ago'),
      (65, '2 months ago'),
    ];
    for (final (days, label) in cases) {
      testWidgets('$days days ago -> "$label"', (tester) async {
        await pumpCard(tester, now.subtract(Duration(days: days)),
            isPast: true);
        expect(find.text(label), findsOneWidget);
      });
    }

    testWidgets('a single month reads "1 month ago"', (tester) async {
      await pumpCard(tester, now.subtract(const Duration(days: 40)),
          isPast: true);
      expect(find.text('1 month ago'), findsOneWidget);
    });
  });
}
