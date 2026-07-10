import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppDecoration {
  // --- Shadows ---
  static List<BoxShadow> shadowXs = [
    BoxShadow(
      color: AppColors.textBlack.withValues(alpha: 0.12),
      blurRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
  ];

  // --- Backgrounds ---
  static final BoxDecoration whiteOverlayGradientCircle = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.18),
        Colors.white.withValues(alpha: 0.1),
      ],
    ),
  );

  static final BoxDecoration whiteOverlayGradientCircleAlt = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Colors.white.withValues(alpha: 0.18),
        Colors.white.withValues(alpha: 0.1),
      ],
    ),
  );
}
