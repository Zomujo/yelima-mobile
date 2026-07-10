import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_paths.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../daily_check_in_card.dart';
import '../action_card.dart';

class HomeNextStepSection extends StatelessWidget {
  const HomeNextStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: AppText.labelLarge(
            'NEXT STEP',
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack.withValues(alpha: 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DailyCheckInCard(
            onStart: () {
              context.push(RoutePaths.aiChat);
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: ActionCard(
                  title: 'My Medicines',
               
                  iconPath: AppImages.pillIcon.assetName,
                  bgImagePath: AppImages.medicineBgIcon.assetName,
                  backgroundColor: const Color(0xFF20C7D3),
                  onTap: () {
                    context.push(RoutePaths.medications);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionCard(
                  title: 'Your Progress',
                  iconPath: AppImages.progressIcon.assetName,
                  bgImagePath: AppImages.progressBgIcon.assetName,
                  backgroundColor: const Color(0xFF37D2B8),
                  onTap: () {
                    context.push(RoutePaths.progress);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
