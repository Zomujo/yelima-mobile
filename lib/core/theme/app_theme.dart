import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'ProductSans',
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.globalBackground,
      cardColor: AppColors.cardBgLightGreen,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          // Status bar background matches the app's cream background
          statusBarColor: AppColors.globalBackground,
          // Dark icons for the light cream background
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light, // iOS
          // Navigation bar (bottom) matches the app's cream background
          systemNavigationBarColor: AppColors.globalBackground,
          // Dark icons so they're visible on the light cream navigation bar
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        backgroundColor: AppColors.globalBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryGreen,
        surface: AppColors.globalBackground,
        error: Colors.red,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textBlack),
        bodyMedium: TextStyle(color: AppColors.textGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppThemeExtension(
          textGrey: AppColors.textGrey,
          textBlack: AppColors.textBlack,
          textWhite: AppColors.textWhite,
          textDarkGreen: AppColors.darkGreen,
          primaryGreen: AppColors.primaryGreen,
          primaryOrange: AppColors.primary,
          cardBgLightGreen: AppColors.cardBgLightGreen,
          cardBgMint: AppColors.cardBgMint,
          circleBgLightOrange: AppColors.circleBgLightOrange,
        ),
      ],
    );
  }
}
