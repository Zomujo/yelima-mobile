import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/shared/widgets/forms/search_suggestions.dart';

import '../../helpers/pump_app.dart';

void main() {
  test('only the newest search returns a result', () async {
    final search = LatestSearch();

    final first = search.run(() async => 'first');
    final second = search.run(() async => 'second');

    expect(await first, isNull);
    expect(await second, 'second');
  });

  testWidgets('a tapped row reports its index', (tester) async {
    int? tapped;
    await tester.pumpApp(
        SuggestionList(items: const ['A', 'B'], onTap: (i) => tapped = i));

    await tester.tap(find.text('B'));

    expect(tapped, 1);
  });

  testWidgets('a message replaces the rows', (tester) async {
    await tester
        .pumpApp(const SuggestionList(items: ['A'], message: 'Nothing found'));

    expect(find.text('Nothing found'), findsOneWidget);
    expect(find.text('A'), findsNothing);
  });
}
