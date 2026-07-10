import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/legal_links.dart';

class TermsAndPrivacyText extends StatelessWidget {
  const TermsAndPrivacyText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text.rich(
        TextSpan(
          text: 'By continuing, you agree to our ',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          children: [
            TextSpan(
              text: 'Terms of Service',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => LegalLinks.launchTerms(),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => LegalLinks.launchPrivacy(),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
