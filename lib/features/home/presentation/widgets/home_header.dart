import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';

class HomeHeader extends StatelessWidget {
  final String date;
  final String greeting;

  const HomeHeader({
    super.key,
    required this.date,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyLarge(
            date,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 4),
          AppText.headlineSmall(
            greeting,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B), // Dark blueish gray
          ),
        ],
      ),
    );
  }
}
