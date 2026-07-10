import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';

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
          border:
              Border.all(color: const Color(0xFFE2E8F0)), // Light grey border
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
              color: const Color(0xFF1E293B),
            ),
          ],
        ),
      ),
    );
  }
}
