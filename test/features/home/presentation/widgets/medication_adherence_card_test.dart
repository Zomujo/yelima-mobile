import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/home/presentation/widgets/medication_adherence_card.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('says the rate covers the last 7 days, not the month',
      (tester) async {
    await tester.pumpApp(
        const MedicationAdherenceCard(percentage: 0.75, message: 'Keep going'));
    await tester.pumpAndSettle(); // the rate counts up first

    expect(find.text('Medication adherence'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
  });
}
