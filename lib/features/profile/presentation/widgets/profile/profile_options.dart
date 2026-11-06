import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_keys.dart';

import '../../../../../core/core_providers.dart';
import '../../../../../core/router/route_paths.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../../../../shared/widgets/layout/options_block.dart';
import '../../../../../shared/widgets/motion/entrance.dart';
import '../../../../auth/presentation/widgets/logout_modal.dart';
import '../language_picker_modal.dart';

/// The profile tab's option groups, arriving one after another the first time.
class ProfileOptions extends ConsumerWidget {
  const ProfileOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isOnline = ref.watch(onlineProvider).valueOrNull ?? true;
    final languageCode =
        ref.watch(localeControllerProvider)?.languageCode ?? 'en';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: Entrance.staggered(startAt: 1, playOnce: 'profile', [
        OptionsBlock(
          key: AppTutorialKeys.profilePersonalOptionsKey,
          title: l10n.personal,
          blockItems: [
            OptionBlockItem(
              label: l10n.editProfile,
              icon: Iconsax.profile_circle,
              onTap: isOnline
                  ? () => context.push(RoutePaths.editProfile)
                  : () => AppSnackBar.showError(context,
                      message: l10n.onlineToEditProfile),
            ),
            OptionBlockItem(
              label: l10n.settings,
              icon: Iconsax.setting_2,
              onTap: () => context.push(RoutePaths.settings),
            ),
          ],
        ),
        OptionsBlock(
          key: AppTutorialKeys.profileHealthSummaryOptionsKey,
          title: l10n.healthSummary,
          blockItems: [
            OptionBlockItem(
              label: l10n.conditions,
              icon: Iconsax.health,
              onTap: () => context.push(RoutePaths.healthProfile),
            ),
          ],
        ),
        OptionsBlock(
          key: AppTutorialKeys.profileLanguageOptionsKey,
          title: l10n.language,
          blockItems: [
            OptionBlockItem(
              label: l10n.languageName(languageCode),
              icon: Iconsax.language_square,
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppColors.slate500),
              onTap: () => LanguagePickerModal.show(context),
            ),
          ],
        ),
        OptionsBlock(
          key: AppTutorialKeys.profileSystemOptionsKey,
          title: l10n.system,
          blockItems: [
            OptionBlockItem(
              label: l10n.logOut,
              icon: Iconsax.logout,
              iconColor: Colors.red,
              labelColor: Colors.red,
              onTap: () => LogoutModal.show(context),
            ),
          ],
        ),
      ]),
    );
  }
}
