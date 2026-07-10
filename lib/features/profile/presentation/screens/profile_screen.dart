import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/options_block.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../auth/presentation/widgets/logout_modal.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../shared/utils/app_snackbar.dart';
import '../widgets/profile/profile_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Off-white
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: AppText.headlineSmall(
                'My Account',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A), // Slate 900
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ProfileAvatar(),
                    const SizedBox(height: 40),

                    // Options Blocks
                    StreamBuilder<bool>(
                        stream: ConnectivityService().onConnectivityChanged,
                        initialData: true,
                        builder: (context, snapshot) {
                          final isOnline = snapshot.data ?? true;
                          return OptionsBlock(
                            title: 'Personal',
                            blockItems: [
                              OptionBlockItem(
                                label: 'Edit profile',
                                icon: Iconsax.profile_circle,
                                onTap: isOnline
                                    ? () => context.push('/edit-profile')
                                    : () => AppSnackBar.showError(context,
                                        message:
                                            'You must be online to edit your profile.'),
                              ),
                              OptionBlockItem(
                                label: 'Settings',
                                icon: Iconsax.setting_2,
                                onTap: () => context.push('/settings'),
                              ),
                            ],
                          );
                        }),

                    OptionsBlock(
                      title: 'Health Summary',
                      blockItems: [
                        OptionBlockItem(
                          label: 'Conditions',
                          icon: Iconsax.health,
                          onTap: () => context.push('/conditions'),
                        ),
                      ],
                    ),

                    OptionsBlock(
                      title: 'System',
                      blockItems: [
                        OptionBlockItem(
                          label: 'Log Out',
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
