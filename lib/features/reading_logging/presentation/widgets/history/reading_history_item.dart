import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';

class ReadingHistoryItem extends StatelessWidget {
  final String date;
  final String bp;
  final String sugar;

  const ReadingHistoryItem({
    super.key,
    required this.date,
    required this.bp,
    required this.sugar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.labelLarge(
          date,
          color: const Color(0xFF94A3B8), // Slate 400
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const AppText.bodyMedium(
              'BP - ',
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569), // Slate 600
            ),
            AppText.bodyMedium(
              bp,
              color: const Color(0xFF475569),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const AppText.bodyMedium(
              'Sugar - ',
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
            AppText.bodyMedium(
              sugar,
              color: const Color(0xFF475569),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(
          color: Colors.grey.shade200,
          thickness: 1,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
