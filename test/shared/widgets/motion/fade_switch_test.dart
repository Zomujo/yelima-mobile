import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/shared/widgets/motion/fade_switch.dart';

Widget _app(String text, {bool reduced = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: FadeSwitch(id: text, child: Text(text)),
      ),
    );

void main() {
  testWidgets('a new value cross-fades in over the old one', (tester) async {
    await tester.pumpWidget(_app('Hello'));
    await tester.pumpWidget(_app('Akwaaba'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Hello'), findsOneWidget, reason: 'still fading out');
    expect(find.text('Akwaaba'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
    expect(find.text('Akwaaba'), findsOneWidget);
  });

  testWidgets('with animations off, the new value shows at once',
      (tester) async {
    await tester.pumpWidget(_app('Hello', reduced: true));
    await tester.pumpWidget(_app('Akwaaba', reduced: true));
    await tester.pump();
    expect(find.text('Hello'), findsNothing);
    expect(find.text('Akwaaba'), findsOneWidget);
  });
}
