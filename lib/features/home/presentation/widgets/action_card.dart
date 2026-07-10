import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/layout/app_text.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final String bgImagePath;
  final Color backgroundColor;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.bgImagePath,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: backgroundColor,
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Background SVG
            Positioned.fill(
              child: SvgPicture.asset(
                bgImagePath,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      iconPath,
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppText.titleMedium(
                    title,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
