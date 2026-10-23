import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';

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
          color: AppColors.slate400,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            AppText.bodyMedium(
              '$vitalName - ',
              fontWeight: FontWeight.bold,
              color: AppColors.slate600,
            ),
            AppText.bodyMedium(
              vitalValue,
              color: AppColors.slate600,
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
                _getSeverityText(context, severity!),
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

  String _getSeverityText(BuildContext context, VitalSeverity sev) {
    final l10n = context.l10n;
    switch (sev) {
      case VitalSeverity.normal:
        return l10n.severityNormal;
      case VitalSeverity.slightlyHigh:
        return l10n.severitySlightlyHigh;
      case VitalSeverity.low:
        return l10n.severityLow;
      case VitalSeverity.criticallyLow:
        return l10n.severityCriticallyLow;
      case VitalSeverity.high:
        return l10n.severityHigh;
      case VitalSeverity.veryHigh:
        return l10n.severityVeryHigh;
      case VitalSeverity.critical:
        return l10n.severityCritical;
      case VitalSeverity.unknown:
        return '';
    }
  }
}
