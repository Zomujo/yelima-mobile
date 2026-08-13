import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_paths.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../daily_check_in_card.dart';
import '../action_card.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../../core/utils/app_tutorial_keys.dart';

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
            context.l10n.nextStep,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack.withValues(alpha: 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DailyCheckInCard(
            key: AppTutorialKeys.homeDailyCheckInKey,
            onStart: () {
              context.push(RoutePaths.aiChat);
            },
          ),
        ),
        const SizedBox(height: 16),
        Column(
          key: AppTutorialKeys.homeActionCardsKey,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ActionCard(
                        title: context.l10n.reportSymptom,
                        iconPath: AppImages.symptoms.assetName,
                        bgImagePath: AppImages.medicineBgIcon.assetName,
                        backgroundColor: const Color(0xFF6750A4),
                        onTap: () {
                          context.push(RoutePaths.symptoms);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionCard(
                        title: context.l10n.recordVitals,
                        iconPath: AppImages.numbers.assetName,
                        bgImagePath: AppImages.progressBgIcon.assetName,
                        backgroundColor: const Color(0xFFE8B931),
                        onTap: () {
                          context.go(RoutePaths.readingLogging);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ActionCard(
                        title: context.l10n.myMedicines,
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
                        title: context.l10n.yourProgress,
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
            ),
          ],
        ),
      ],
    );
  }
}
