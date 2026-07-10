import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color? textGrey;
  final Color? textBlack;
  final Color? textWhite;
  final Color? textDarkGreen;
  final Color? primaryGreen;
  final Color? primaryOrange;
  final Color? cardBgLightGreen;
  final Color? cardBgMint;

  final Color? circleBgLightOrange;

  const AppThemeExtension({
    required this.textGrey,
    required this.textBlack,
    required this.textWhite,
    required this.textDarkGreen,
    required this.primaryGreen,
    required this.primaryOrange,
    required this.cardBgLightGreen,
    required this.cardBgMint,

    required this.circleBgLightOrange,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? textGrey,
    Color? textBlack,
    Color? textWhite,
    Color? textDarkGreen,
    Color? primaryGreen,
    Color? primaryOrange,
    Color? cardBgLightGreen,
    Color? cardBgMint,

    Color? circleBgLightOrange,
  }) {
    return AppThemeExtension(
      textGrey: textGrey ?? this.textGrey,
      textBlack: textBlack ?? this.textBlack,
      textWhite: textWhite ?? this.textWhite,
      textDarkGreen: textDarkGreen ?? this.textDarkGreen,
      primaryGreen: primaryGreen ?? this.primaryGreen,
      primaryOrange: primaryOrange ?? this.primaryOrange,
      cardBgLightGreen: cardBgLightGreen ?? this.cardBgLightGreen,
      cardBgMint: cardBgMint ?? this.cardBgMint,

      circleBgLightOrange: circleBgLightOrange ?? this.circleBgLightOrange,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      textGrey: Color.lerp(textGrey, other.textGrey, t),
      textBlack: Color.lerp(textBlack, other.textBlack, t),
      textWhite: Color.lerp(textWhite, other.textWhite, t),
      textDarkGreen: Color.lerp(textDarkGreen, other.textDarkGreen, t),
      primaryGreen: Color.lerp(primaryGreen, other.primaryGreen, t),
      primaryOrange: Color.lerp(primaryOrange, other.primaryOrange, t),
      cardBgLightGreen: Color.lerp(cardBgLightGreen, other.cardBgLightGreen, t),
      cardBgMint: Color.lerp(cardBgMint, other.cardBgMint, t),

      circleBgLightOrange: Color.lerp(circleBgLightOrange, other.circleBgLightOrange, t),
    );
  }
}
