import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand & Primary Colors ──
  static const Color primary = Color(0xFFF9B678); // Orange-ish buttons
  static const Color primaryGreen = Color(0xFF16A34A); // Green text and icon
  static const Color darkGreen = Color(0xFF166534); // Dark green text

  // ── Background Colors ──
  static const Color globalBackground = Color(0xFFFDFAF4); // Off-white/cream
  static const Color cardBgLightGreen = Color(0xFFD1F2D8); // Card background
  static const Color cardBgMint = Color(0xFFD0FAE5); // Two cards use this

  static const Color circleBgLightOrange = Color(0xFFFDE8D8); // Circles

  // ── Text Colors ──
  static const Color textGrey = Color(0xFF99A1AF); // Grey text
  static const Color textBlack = Color(0xFF000000); // Black text
  static const Color textWhite = Color(0xFFFFFFFF); // White text

  // ── Neutrals and accents (Tailwind scale) ──
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color red500 = Color(0xFFEF4444);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color offWhite = Color(0xFFFAF9F6);

  // ── Gradients ──
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF9B678), Color(0xFFFF8C22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF82C76F), Color(0xFF009D3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient complexOrangeGradient = LinearGradient(
    colors: [Color(0xFFF9B678), Color(0xFFFFB977), Color(0xFFFF9737)],
    stops: [0.0, 0.6, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient homeBackgroundGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0x92CCFEFC),
      Color(0xFFFDFAF4),
      Color(0xBCFFF5E2),
    ],
    stops: [
      0.0,
      0.5,
      1.0,
    ],
  );
}
