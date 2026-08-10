import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/legal_links.dart';
import '../../../../core/extensions/l10n_extension.dart';

class TermsAndPrivacyText extends StatelessWidget {
  const TermsAndPrivacyText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text.rich(
        TextSpan(
          text: context.l10n.byContinuing,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          children: [
            TextSpan(
              text: context.l10n.termsOfService,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => LegalLinks.launchTerms(),
            ),
            TextSpan(text: context.l10n.andText),
            TextSpan(
              text: context.l10n.privacyPolicy,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => LegalLinks.launchPrivacy(),
            ),
            if (context.l10n.termsSuffix.isNotEmpty)
              TextSpan(text: context.l10n.termsSuffix),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
