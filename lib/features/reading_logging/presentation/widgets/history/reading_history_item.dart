import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';

class ReadingHistoryItem extends StatelessWidget {
  final String date;
  final String vitalName;
  final String vitalValue;

  const ReadingHistoryItem({
    super.key,
    required this.date,
    required this.vitalName,
    required this.vitalValue,
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
            AppText.bodyMedium(
              '$vitalName - ',
              fontWeight: FontWeight.bold,
              color: const Color(0xFF475569), // Slate 600
            ),
            AppText.bodyMedium(
              vitalValue,
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
