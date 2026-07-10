import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_text.dart';

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
              Color(0xFFCBD5E1),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          AppText.bodyMedium(
            title,
            color: const Color(0xFF94A3B8),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
