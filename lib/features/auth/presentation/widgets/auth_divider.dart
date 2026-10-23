import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../core/extensions/l10n_extension.dart';

/// The "or" line between Google and email sign-in.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.slate200, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppText.bodyMedium(
            context.l10n.orUseEmail,
            color: AppColors.slate400,
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.slate200, thickness: 1),
        ),
      ],
    );
  }
}
