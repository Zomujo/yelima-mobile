import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/motion/entrance.dart';

/// The shared frame of the auth screens: title, subtitle and content.
/// The heading fades up while the white panel slides up from the bottom.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  /// Stagger index for the panel's own content: it starts as the panel arrives.
  static const firstItem = 1;

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                top: 48,
                right: 24,
                bottom: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: Entrance.staggered([
                  AppText.headlineLarge(
                    title,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                  ),
                  AppText.bodyLarge(
                    subtitle,
                    color: AppColors.slate600,
                  ),
                ]),
              ),
            ),
            Expanded(
              child: Entrance(
                index: 1,
                rise: 48,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
