import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../shared/widgets/motion/entrance.dart';
import '../../../user/user_providers.dart';
import '../widgets/health_profile_card.dart';
import '../widgets/health_expansion_card.dart';
import '../widgets/health_info_card.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// The patient's details and chronic conditions.
class HealthProfileScreen extends ConsumerWidget {
  const HealthProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider).userEntity;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppHeader(
        title: context.l10n.healthProfile,
        onBackPressed: () => context.pop(),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              if (user != null) Entrance(child: HealthProfileCard(user: user)),
              const SizedBox(height: 24),
              if (user != null)
                Entrance(
                  index: 1,
                  child: HealthExpansionCard(
                    title: context.l10n.chronicConditions,
                    icon: Iconsax.activity,
                    child: user.conditions.isEmpty
                        ? AppText.bodyMedium(
                            context.l10n.noChronicConditionsReported,
                            color: AppColors.slate500)
                        : Column(children: [
                            for (final condition in user.conditions)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: HealthInfoCard(
                                  title: context.l10n.conditionName(condition),
                                  status: context.l10n.active,
                                ),
                              ),
                          ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
