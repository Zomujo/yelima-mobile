import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../user/presentation/controllers/user_controller.dart';
import '../../../../user/presentation/widgets/user_avatar.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// The patient's avatar, name and role at the top of the profile tab.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserController>().userEntity;
    final name = user?.fullName ?? '';

    return Center(
      child: Column(
        children: [
          UserAvatar(user: user),
          const SizedBox(height: 16),
          AppText.titleLarge(
            name.isEmpty ? context.l10n.unknownUser : name,
            fontWeight: FontWeight.w600,
            color: AppColors.slate800,
          ),
          const SizedBox(height: 4),
          AppText.bodyMedium(
            context.l10n.patient,
            color: AppColors.slate500,
          ),
        ],
      ),
    );
  }
}
