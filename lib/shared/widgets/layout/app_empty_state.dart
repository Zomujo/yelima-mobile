import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'tinted_svg.dart';
import '../motion/entrance.dart';
import 'app_text.dart';

/// An icon and message for an empty list.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String iconAsset;
  final double iconSize;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.iconAsset,
    this.iconSize = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Entrance(
        rise: 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TintedSvg(iconAsset, color: AppColors.slate300, size: iconSize),
            const SizedBox(height: 16),
            AppText.bodyMedium(
              title,
              color: AppColors.slate400,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
