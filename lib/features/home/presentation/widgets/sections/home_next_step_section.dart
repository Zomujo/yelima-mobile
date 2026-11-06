import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/config/features.dart';
import '../../../../../core/router/route_paths.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/motion/entrance.dart';
import '../daily_check_in_card.dart';
import '../action_card.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_keys.dart';

/// What to do next: log a reading or take a dose.
class HomeNextStepSection extends StatelessWidget {
  final Widget? topSlotWidget;

  const HomeNextStepSection({super.key, this.topSlotWidget});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = Entrance.staggered(playOnce: 'home/actions', startAt: 3, [
      ActionCard(
        title: l10n.reportSymptom,
        iconPath: AppImages.symptoms.assetName,
        bgImagePath: AppImages.medicineBgIcon.assetName,
        backgroundColor: const Color(0xFF6750A4),
        onTap: () => context.push(RoutePaths.symptoms),
      ),
      ActionCard(
        title: l10n.recordVitals,
        iconPath: AppImages.numbers.assetName,
        bgImagePath: AppImages.progressBgIcon.assetName,
        backgroundColor: const Color(0xFFE8B931),
        onTap: () => context.go(RoutePaths.readingLogging),
      ),
      ActionCard(
        title: l10n.myMedicines,
        iconPath: AppImages.pillIcon.assetName,
        bgImagePath: AppImages.medicineBgIcon.assetName,
        backgroundColor: const Color(0xFF20C7D3),
        onTap: () => context.push(RoutePaths.medications),
      ),
      ActionCard(
        title: l10n.yourProgress,
        iconPath: AppImages.progressIcon.assetName,
        bgImagePath: AppImages.progressBgIcon.assetName,
        backgroundColor: const Color(0xFF37D2B8),
        onTap: () => context.push(RoutePaths.progress),
      ),
    ]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Entrance(
          index: 3,
          playOnce: 'home/nextStep',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: AppText.labelLarge(
              l10n.nextStep,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack.withValues(alpha: 0.5),
            ),
          ),
        ),
        if (topSlotWidget != null) ...[
          topSlotWidget!,
          const SizedBox(height: 10),
        ],
        Column(
          key: AppTutorialKeys.homeActionCardsKey,
          children: [
            _CardPair(cards[0], cards[1]),
            const SizedBox(height: 12),
            _CardPair(cards[2], cards[3]),
          ],
        ),
        if (Features.aiChat) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: DailyCheckInCard(
              key: AppTutorialKeys.homeDailyCheckInKey,
              onStart: () => context.push(RoutePaths.aiChat),
            ),
          ),
        ],
      ],
    );
  }
}

/// Two action cards side by side, the same height.
class _CardPair extends StatelessWidget {
  const _CardPair(this.left, this.right);

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        ),
      ),
    );
  }
}
