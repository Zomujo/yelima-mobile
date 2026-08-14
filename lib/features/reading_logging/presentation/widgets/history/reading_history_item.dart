import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';

class ReadingHistoryItem extends StatelessWidget {
  final String date;
  final String vitalName;
  final String vitalValue;
  final String? severity;

  const ReadingHistoryItem({
    super.key,
    required this.date,
    required this.vitalName,
    required this.vitalValue,
    this.severity,
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
            if (severity != null) ...[
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getSeverityColor(severity!),
                ),
              ),
              const SizedBox(width: 4),
              AppText.bodySmall(
                _getSeverityText(severity!),
                color: _getSeverityColor(severity!),
                fontWeight: FontWeight.w600,
              ),
            ],
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

  Color _getSeverityColor(String sev) {
    switch (sev.toLowerCase()) {
      case 'in_target':
      case 'good':
      case 'normal':
        return Colors.green;
      case 'slightly_high':
      case 'low':
      case 'elevated':
        return Colors.amber.shade700;
      case 'high':
        return Colors.orange.shade700;
      case 'very_high':
      case 'critically_low':
        return Colors.deepOrange;
      case 'critical':
      case 'crisis':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityText(String sev) {
    switch (sev.toLowerCase()) {
      case 'in_target':
        return 'In Target';
      case 'slightly_high':
        return 'Slightly High';
      case 'very_high':
        return 'Very High';
      case 'critically_low':
        return 'Critically Low';
      case 'good':
        return 'Good';
      case 'normal':
        return 'Normal';
      case 'low':
        return 'Low';
      case 'elevated':
        return 'Elevated';
      case 'high':
        return 'High';
      case 'critical':
        return 'Critical';
      case 'crisis':
        return 'Crisis';
      default:
        return '';
    }
  }
}
