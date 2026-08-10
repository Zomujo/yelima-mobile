import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/l10n_extension.dart';
import 'app_text.dart';
import 'app_button.dart';

class StepLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String continueText;
  final bool isContinueEnabled;
  final bool isSubmitting;

  const StepLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
    this.onContinue,
    this.continueText = 'Continue',
    this.isContinueEnabled = true,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          AppText.headlineMedium(
            title,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
          const SizedBox(height: 8),
          AppText.bodyLarge(
            subtitle,
            color: const Color(0xFF6A7282),
            height: 1.5,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  child,
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 16),
            child: onBack != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBackButton(context),
                      _buildContinueButton(),
                    ],
                  )
                : Align(
                    alignment: Alignment.centerRight,
                    child: _buildContinueButton(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting ? null : onBack,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const Icon(Icons.chevron_left, color: Color(0xFF64748B), size: 20),
            const SizedBox(width: 8),
            AppText.bodyLarge(
              context.l10n.backText,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return AppButton(
      text: continueText,
      onPressed: (isContinueEnabled && !isSubmitting) ? onContinue : null,
      backgroundColor: (isContinueEnabled && !isSubmitting)
          ? AppColors.primary
          : const Color(0xFF94A3B8),
      width: 160,
      height: 50,
      borderRadius: 24,
      suffixIcon: isSubmitting
          ? null
          : const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 12,
            ),
    );
  }
}
