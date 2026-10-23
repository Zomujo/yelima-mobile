import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';

/// A bordered button for signing in with a provider such as Google.
class SocialAuthButton extends StatelessWidget {
  final ImageProvider icon;
  final String text;
  final VoidCallback? onPressed;

  const SocialAuthButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.slate200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: icon, height: 24, width: 24),
            const SizedBox(width: 12),
            AppText.bodyLarge(
              text,
              fontWeight: FontWeight.w500,
              color: AppColors.slate800,
            ),
          ],
        ),
      ),
    );
  }
}
