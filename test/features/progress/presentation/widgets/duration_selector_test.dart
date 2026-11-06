import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/progress/domain/entities/vital_trends.dart';
import 'package:yelima/features/progress/presentation/widgets/duration_selector.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('the pill sits under the chosen range and a tap picks another',
      (tester) async {
    ChartDateRange? picked;
    await tester.pumpApp(DurationSelector(
        range: ChartDateRange.thisWeek, onChanged: (r) => picked = r));

    final pill = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
    expect(pill.alignment, Alignment.center);

    await tester.tap(find.text('1 Month'));
    expect(picked, ChartDateRange.thisMonth);
  });
}
