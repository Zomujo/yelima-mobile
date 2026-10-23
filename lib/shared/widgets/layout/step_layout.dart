import 'package:flutter/material.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'app_text.dart';
import 'app_button.dart';

/// A registration step: title, subtitle, content, and Back/Continue buttons.
class StepLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final bool isContinueEnabled;

  const StepLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
    this.onContinue,
    this.isContinueEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                AppText.headlineMedium(
                  title,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate800,
                ),
                const SizedBox(height: 8),
                AppText.bodyLarge(
                  subtitle,
                  color: const Color(0xFF6A7282),
                  height: 1.5,
                ),
                const SizedBox(height: 32),
                child,
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 16),
                  child: onBack != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBackButton(context),
                            _buildContinueButton(context),
                          ],
                        )
                      : Align(
                          alignment: Alignment.centerRight,
                          child: _buildContinueButton(context),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.slate200),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const Icon(Icons.chevron_left, color: AppColors.slate500, size: 20),
            const SizedBox(width: 8),
            AppText.bodyLarge(
              context.l10n.backText,
              fontWeight: FontWeight.w600,
              color: AppColors.slate600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return AppButton(
      text: context.l10n.continueText,
      onPressed: isContinueEnabled ? onContinue : null,
      backgroundColor:
          isContinueEnabled ? AppColors.primary : AppColors.slate400,
      width: 160,
      height: 50,
      borderRadius: 24,
      suffixIcon:
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
    );
  }
}
