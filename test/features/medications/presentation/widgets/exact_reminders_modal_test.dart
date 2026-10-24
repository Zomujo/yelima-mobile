import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/presentation/widgets/exact_reminders_modal.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Future<bool?> answer(WidgetTester tester, String button) async {
    bool? result;
    await tester.pumpApp(Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await ExactRemindersModal.show(context),
        child: const Text('open'),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Get reminders on time'), findsOneWidget);
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('Allow goes on to the setting', (tester) async {
    expect(await answer(tester, 'Allow'), isTrue);
  });

  testWidgets('Not now leaves it', (tester) async {
    expect(await answer(tester, 'Not now'), isFalse);
  });
}
