import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';

class MedicationAdherenceCard extends StatelessWidget {
  final double percentage;
  final String message;
  final bool isLoading;

  const MedicationAdherenceCard({
    super.key,
    required this.percentage,
    required this.message,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText.bodyMedium(
                'Medication adherence this month',
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              if (isLoading)
                AppShimmer.box(width: 48, height: 24)
              else
                AppText.titleMedium(
                  '${(percentage * 100).toInt()}%',
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isLoading
                ? AppShimmer.box(height: 8, width: double.infinity)
                : LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  ),
          ),
          const SizedBox(height: 6),
          if (isLoading)
            AppShimmer.box(height: 16, width: 200)
          else
            AppText.labelMedium(
              message,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w400,
            ),
        ],
      ),
    );
  }
}
