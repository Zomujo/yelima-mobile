import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/shared/widgets/motion/count_up.dart';
import 'package:yelima/shared/widgets/motion/entrance.dart';
import 'package:yelima/shared/widgets/motion/pressable.dart';

Widget _app(Widget child, {bool reduced = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(body: Center(child: child)),
      ),
    );

double _opacity(WidgetTester tester, String text) {
  final fades = tester.widgetList<FadeTransition>(find.ancestor(
      of: find.text(text), matching: find.byType(FadeTransition)));
  return fades.fold(1.0, (o, f) => o * f.opacity.value);
}

void main() {
  testWidgets('an entrance fades in, and later items start later',
      (tester) async {
    await tester.pumpWidget(_app(Column(
        children: Entrance.staggered([const Text('a'), const Text('b')]))));
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
    expect(_opacity(tester, 'a'), greaterThan(_opacity(tester, 'b')));

    await tester.pumpAndSettle();
    expect(_opacity(tester, 'a'), 1);
    expect(_opacity(tester, 'b'), 1);
  });

  testWidgets('with animations off, everything shows at once', (tester) async {
    await tester.pumpWidget(
        _app(const Entrance(child: Text('a')), reduced: true));
    expect(_opacity(tester, 'a'), 1);
  });

  testWidgets('an entrance with playOnce plays only the first time',
      (tester) async {
    await tester.pumpWidget(
        _app(const Entrance(playOnce: 'test.tab', child: Text('a'))));
    await tester.pump(const Duration(milliseconds: 50));
    expect(_opacity(tester, 'a'), lessThan(1));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_app(const SizedBox()));
    await tester.pumpWidget(
        _app(const Entrance(playOnce: 'test.tab', child: Text('a'))));
    expect(_opacity(tester, 'a'), 1);
  });

  testWidgets('a pressed widget shrinks, then springs back', (tester) async {
    await tester.pumpWidget(_app(const Pressable(child: Text('tap'))));
    final gesture = await tester.startGesture(tester.getCenter(find.text('tap')));
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 0.97);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });

  testWidgets('a number counts up to its value', (tester) async {
    await tester.pumpWidget(_app(CountUp(
        value: 40,
        builder: (_, v) => Text(v.round().toString()))));
    expect(find.text('0'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('40'), findsOneWidget);
  });

  testWidgets('dragging a pressed widget (a scroll) lets it go', (tester) async {
    await tester.pumpWidget(_app(const Pressable(child: Text('tap'))));
    final gesture = await tester.startGesture(tester.getCenter(find.text('tap')));
    await tester.pumpAndSettle();
    await gesture.moveBy(const Offset(0, 40));
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await gesture.up();
  });
}
