import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/config/features.dart';
import 'package:yelima/features/home/presentation/widgets/daily_check_in_card.dart';
import 'package:yelima/features/home/presentation/widgets/home_bottom_navbar.dart';
import 'package:yelima/features/home/presentation/widgets/sections/home_next_step_section.dart';

import '../../../helpers/pump_app.dart';

void main() {
  test('the AI chat is switched off for now', () {
    expect(Features.aiChat, isFalse);
  });

  testWidgets('home has no daily check-in card while the chat is hidden',
      (tester) async {
    await tester
        .pumpApp(const SingleChildScrollView(child: HomeNextStepSection()));

    expect(find.byType(DailyCheckInCard), findsNothing);
  });

  testWidgets('the bottom bar has four tabs, without chat', (tester) async {
    await tester.pumpApp(const HomeBottomNavBar());

    expect(
        find.descendant(
            of: find.byType(HomeBottomNavBar),
            matching: find.byType(GestureDetector)),
        findsNWidgets(4));
  });
}
