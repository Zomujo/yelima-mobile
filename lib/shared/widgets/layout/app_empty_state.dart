import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: iconSize,
            height: iconSize,
            colorFilter: const ColorFilter.mode(
              AppColors.slate300,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          AppText.bodyMedium(
            title,
            color: AppColors.slate400,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
