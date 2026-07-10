import 'package:flutter/material.dart';
import '../../../../core/constants/app_decoration.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_button.dart';

class DailyCheckInCard extends StatelessWidget {
  final VoidCallback onStart;

  const DailyCheckInCard({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.orangeGradient,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: AppDecoration.whiteOverlayGradientCircleAlt,
            ),
          ),
          Positioned(
            right: -20,
            bottom: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: AppDecoration.whiteOverlayGradientCircle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText.labelMedium(
                  'DAILY CHECK-IN',
                  color: Color(0xD1FFFFFF),
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                const AppText(
                  "Tell Yelima how you're feeling\ntoday?",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  variant: AppTextVariant.titleMedium,
                  height: 1.3,
                ),
                const SizedBox(height: 8),
                const AppText.bodyMedium(
                  "It only takes 2 minutes. Your nurse will see\nyour report.",
                  color: Color.fromARGB(231, 255, 255, 255),
                  height: 1.2,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 34),
                AppButton(
                  text: 'Start check-in',
                  onPressed: onStart,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  borderRadius: 24,
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  suffixIcon: const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
