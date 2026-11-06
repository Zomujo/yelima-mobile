import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/home/presentation/widgets/counting_text.dart';

Widget _app(String text, String key) => MaterialApp(
      home: CountingText(text, playOnce: key, builder: Text.new),
    );

void main() {
  testWidgets('a reading counts up and lands on exactly the given text',
      (tester) async {
    for (final (text, key) in [
      ('5.9', 'test/sugar'),
      ('126', 'test/bp'),
      ('/77', 'test/bpSub'),
    ]) {
      await tester.pumpWidget(_app(text, key));
      expect(find.text(text), findsNothing, reason: '$text starts from zero');
      await tester.pumpAndSettle();
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('keeps the decimals while counting', (tester) async {
    await tester.pumpWidget(_app('5.9', 'test/decimals'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining(RegExp(r'^\d\.\d$')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('text without a number shows as is', (tester) async {
    await tester.pumpWidget(_app('--', 'test/none'));
    expect(find.text('--'), findsOneWidget);
  });
}
