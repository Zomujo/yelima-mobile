import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/options_block.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_paths.dart';
import '../../../auth/presentation/widgets/logout_modal.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../shared/utils/app_snackbar.dart';
import '../widgets/profile/profile_avatar.dart';
import '../widgets/language_picker_modal.dart';
import 'package:provider/provider.dart';
import '../../../../core/controllers/locale_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_service.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_keys.dart';

/// The profile tab: patient details and account options.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppTutorialService.showProfileTutorial(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: AppText.headlineSmall(
                context.l10n.myAccount,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileAvatar(
                      key: AppTutorialKeys.profileAvatarKey,
                    ),
                    const SizedBox(height: 40),
                    StreamBuilder<bool>(
                        stream: ConnectivityService().onNetworkInterfaceChanged,
                        initialData: true,
                        builder: (context, snapshot) {
                          final isOnline = snapshot.data ?? true;
                          return OptionsBlock(
                            key: AppTutorialKeys.profilePersonalOptionsKey,
                            title: context.l10n.personal,
                            blockItems: [
                              OptionBlockItem(
                                label: context.l10n.editProfile,
                                icon: Iconsax.profile_circle,
                                onTap: isOnline
                                    ? () => context.push(RoutePaths.editProfile)
                                    : () => AppSnackBar.showError(context,
                                        message:
                                            context.l10n.onlineToEditProfile),
                              ),
                              OptionBlockItem(
                                label: context.l10n.settings,
                                icon: Iconsax.setting_2,
                                onTap: () => context.push(RoutePaths.settings),
                              ),
                            ],
                          );
                        }),
                    OptionsBlock(
                      key: AppTutorialKeys.profileHealthSummaryOptionsKey,
                      title: context.l10n.healthSummary,
                      blockItems: [
                        OptionBlockItem(
                          label: context.l10n.conditions,
                          icon: Iconsax.health,
                          onTap: () => context.push(RoutePaths.healthProfile),
                        ),
                      ],
                    ),
                    OptionsBlock(
                      key: AppTutorialKeys.profileLanguageOptionsKey,
                      title: context.l10n.language,
                      blockItems: [
                        OptionBlockItem(
                          label: context.l10n.languageName(context
                                  .watch<LocaleController>()
                                  .locale
                                  ?.languageCode ??
                              'en'),
                          icon: Iconsax.language_square,
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16, color: AppColors.slate500),
                          onTap: () {
                            LanguagePickerModal.show(context);
                          },
                        ),
                      ],
                    ),
                    OptionsBlock(
                      key: AppTutorialKeys.profileSystemOptionsKey,
                      title: context.l10n.system,
                      blockItems: [
                        OptionBlockItem(
                          label: context.l10n.logOut,
                          icon: Iconsax.logout,
                          iconColor: Colors.red,
                          labelColor: Colors.red,
                          onTap: () {
                            LogoutModal.show(context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.bottomNavClearance(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
