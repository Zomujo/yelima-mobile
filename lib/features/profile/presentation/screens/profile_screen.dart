import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../core/constants/app_sizes.dart';
import '../widgets/profile/profile_avatar.dart';
import '../widgets/profile/profile_options.dart';
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
                    ProfileAvatar(key: AppTutorialKeys.profileAvatarKey),
                    const SizedBox(height: 40),
                    const ProfileOptions(),
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
