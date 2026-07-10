import 'package:flutter/material.dart';

enum AppTextVariant {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final FontWeight? fontWeight;
  final bool softWrap;
  final TextDecoration? decoration;
  final double? letterSpacing;

  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.fontWeight,
    this.softWrap = true,
    this.decoration,
    this.letterSpacing,
  });

  // --- Display ---
  const AppText.displayLarge(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.displayLarge;
  const AppText.displayMedium(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.displayMedium;
  const AppText.displaySmall(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.displaySmall;

  // --- Headline ---
  const AppText.headlineLarge(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.headlineLarge;
  const AppText.headlineMedium(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.headlineMedium;
  const AppText.headlineSmall(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.headlineSmall;

  // --- Title ---
  const AppText.titleLarge(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.titleLarge;
  const AppText.titleMedium(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.titleMedium;
  const AppText.titleSmall(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.titleSmall;

  // --- Body ---
  const AppText.bodyLarge(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.bodyLarge;
  const AppText.bodyMedium(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.bodyMedium;
  const AppText.bodySmall(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.bodySmall;

  // --- Label ---
  const AppText.labelLarge(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.labelLarge;
  const AppText.labelMedium(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.labelMedium;
  const AppText.labelSmall(this.text,
      {super.key,
      this.color,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.height,
      this.fontWeight,
      this.softWrap = true,
      this.decoration,
      this.letterSpacing})
      : variant = AppTextVariant.labelSmall;

  TextStyle? _getStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (variant) {
      case AppTextVariant.displayLarge:
        return textTheme.displayLarge;
      case AppTextVariant.displayMedium:
        return textTheme.displayMedium;
      case AppTextVariant.displaySmall:
        return textTheme.displaySmall;
      case AppTextVariant.headlineLarge:
        return textTheme.headlineLarge;
      case AppTextVariant.headlineMedium:
        return textTheme.headlineMedium;
      case AppTextVariant.headlineSmall:
        return textTheme.headlineSmall;
      case AppTextVariant.titleLarge:
        return textTheme.titleLarge;
      case AppTextVariant.titleMedium:
        return textTheme.titleMedium;
      case AppTextVariant.titleSmall:
        return textTheme.titleSmall;
      case AppTextVariant.bodyLarge:
        return textTheme.bodyLarge;
      case AppTextVariant.bodyMedium:
        return textTheme.bodyMedium;
      case AppTextVariant.bodySmall:
        return textTheme.bodySmall;
      case AppTextVariant.labelLarge:
        return textTheme.labelLarge;
      case AppTextVariant.labelMedium:
        return textTheme.labelMedium;
      case AppTextVariant.labelSmall:
        return textTheme.labelSmall;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? baseStyle = _getStyle(context);

    // Apply overrides
    if (baseStyle != null) {
      baseStyle = baseStyle.copyWith(
        color: color,
        height: height,
        fontWeight: fontWeight,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );
    }

    return Text(
      text,
      style: baseStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      softWrap: softWrap,
    );
  }
}
