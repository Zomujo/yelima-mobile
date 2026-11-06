import 'package:flutter/material.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/core/theme/app_motion.dart';

/// A selectable card for one health condition.
class ConditionSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const ConditionSelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final duration =
        AppMotion.duration(context, AppMotion.medium);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: duration,
        curve: AppMotion.move,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.slate200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyLarge(
                    title,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                  ),
                  const SizedBox(height: 4),
                  AppText.bodyMedium(
                    subtitle,
                    color: AppColors.slate400,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _CheckCircle(isSelected: isSelected, duration: duration),
          ],
        ),
      ),
    );
  }
}

/// The round tick: fills green and its white check grows in when selected.
class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.isSelected, required this.duration});

  final bool isSelected;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primaryGreen : AppColors.slate200;
    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.move,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        color: isSelected ? AppColors.primaryGreen : Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.slate200),
          AnimatedScale(
            scale: isSelected ? 1 : 0.5,
            duration: duration,
            curve: AppMotion.enter,
            child: AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: duration,
              curve: AppMotion.enter,
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
