import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:yelima/core/theme/app_motion.dart';

/// Close button, progress bar and "step X of Y" badge.
class RegistrationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onClose;

  const RegistrationAppBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 2,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.slate200),
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.slate500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  for (var i = 0; i < totalSteps; i++)
                    Expanded(child: _Segment(filled: i < currentStep)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FCE3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$currentStep of $totalSteps',
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// One piece of the progress bar; its orange fill grows in from the left.
class _Segment extends StatelessWidget {
  const _Segment({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(2);
    return Container(
      height: 4,
      decoration:
          BoxDecoration(color: AppColors.slate200, borderRadius: radius),
      child: AnimatedFractionallySizedBox(
        duration: AppMotion.duration(context, AppMotion.slow),
        curve: AppMotion.move,
        alignment: Alignment.centerLeft,
        widthFactor: filled ? 1 : 0,
        child: DecoratedBox(
          decoration:
              BoxDecoration(color: AppColors.orange300, borderRadius: radius),
        ),
      ),
    );
  }
}
