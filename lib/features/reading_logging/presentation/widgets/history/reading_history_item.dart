import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import 'package:yelima/features/home/domain/entities/vital_history_entity.dart';

class ReadingHistoryItem extends StatelessWidget {
  final String date;
  final String vitalName;
  final String vitalValue;
  final VitalSeverity? severity;

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

  Color _getSeverityColor(VitalSeverity sev) {
    switch (sev) {
      case VitalSeverity.normal:
        return Colors.green;
      case VitalSeverity.slightlyHigh:
      case VitalSeverity.low:
        return Colors.amber.shade700;
      case VitalSeverity.criticallyLow:
        return Colors.deepOrange;
      case VitalSeverity.high:
        return Colors.orange.shade700;
      case VitalSeverity.veryHigh:
        return Colors.deepOrange;
      case VitalSeverity.critical:
        return Colors.red.shade700;
      case VitalSeverity.unknown:
        return Colors.grey;
    }
  }

  String _getSeverityText(VitalSeverity sev) {
    switch (sev) {
      case VitalSeverity.normal:
        return 'Normal / Target';
      case VitalSeverity.slightlyHigh:
        return 'Slightly High';
      case VitalSeverity.low:
        return 'Low';
      case VitalSeverity.criticallyLow:
        return 'Critically Low';
      case VitalSeverity.high:
        return 'High';
      case VitalSeverity.veryHigh:
        return 'Very High';
      case VitalSeverity.critical:
        return 'Critical';
      case VitalSeverity.unknown:
        return '';
    }
  }
}
