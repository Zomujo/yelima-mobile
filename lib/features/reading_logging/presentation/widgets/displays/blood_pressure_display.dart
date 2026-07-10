import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../shared/widgets/layout/app_text.dart';

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
              const AppText.labelMedium('Systolic', color: AppColors.textGrey),
              const SizedBox(height: 4),
              AppText.displaySmall(
                systolic,
                color: const Color(0xFF1E293B),
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
            color: const Color(0xFFF4F8FF), // Light blue box
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const AppText.labelMedium('Diastolic', color: AppColors.textGrey),
              const SizedBox(height: 4),
              AppText.displaySmall(
                diastolic,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
