import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final String? subValue;
  final String unit;
  final bool isLoading;

  const MetricCard({
    super.key,
    required this.title,
    required this.mainValue,
    this.subValue,
    required this.unit,
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
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (isLoading)
                AppShimmer.box(width: 80, height: 32)
              else ...[
                AppText.headlineMedium(
                  mainValue,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                if (subValue != null)
                  AppText.titleMedium(
                    subValue!,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textGrey,
                  ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          AppText.labelLarge(
            title,
            fontWeight: FontWeight.normal,
            color: AppColors.textGrey,
          ),
          AppText.labelLarge(
            unit,
            color: AppColors.textGrey.withValues(alpha: 0.6),
            fontWeight: FontWeight.w100,
          ),
        ],
      ),
    );
  }
}
