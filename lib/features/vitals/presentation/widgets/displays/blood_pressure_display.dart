import 'package:flutter/material.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// Systolic over diastolic in large type.
class BloodPressureDisplay extends StatelessWidget {
  const BloodPressureDisplay({
    super.key,
    required this.systolic,
    required this.diastolic,
  });

  final String systolic;
  final String diastolic;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              AppText.labelMedium(context.l10n.systolic,
                  color: AppColors.textGrey),
              const SizedBox(height: 4),
              AppText.displaySmall(
                systolic,
                color: AppColors.slate800,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Column(
          children: [
            AppText.displaySmall(
              '/',
              color: Colors.grey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              AppText.labelMedium(context.l10n.diastolic,
                  color: AppColors.textGrey),
              const SizedBox(height: 4),
              AppText.displaySmall(
                diastolic,
                color: AppColors.slate800,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
