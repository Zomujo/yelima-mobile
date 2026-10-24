import 'package:flutter/material.dart';

/// Text styles from the theme.
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

/// Themed text; use the named constructors for each style.
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
  final Color? decorationColor;
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
    this.decorationColor,
    this.letterSpacing,
  });

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
      this.decorationColor,
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
      this.decorationColor,
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
      this.decorationColor,
      this.letterSpacing})
      : variant = AppTextVariant.displaySmall;

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
      this.decorationColor,
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
      this.decorationColor,
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
      this.decorationColor,
      this.letterSpacing})
      : variant = AppTextVariant.headlineSmall;

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
      this.decorationColor,
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
      this.decorationColor,
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
      this.decorationColor,
      this.letterSpacing})
      : variant = AppTextVariant.titleSmall;

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
      this.decorationColor,
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
      this.decorationColor,
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
      this.decorationColor,
      this.letterSpacing})
      : variant = AppTextVariant.bodySmall;

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
      this.decorationColor,
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
      this.decorationColor,
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
      this.decorationColor,
      this.letterSpacing})
      : variant = AppTextVariant.labelSmall;

  TextStyle? _style(TextTheme t) => switch (variant) {
        AppTextVariant.displayLarge => t.displayLarge,
        AppTextVariant.displayMedium => t.displayMedium,
        AppTextVariant.displaySmall => t.displaySmall,
        AppTextVariant.headlineLarge => t.headlineLarge,
        AppTextVariant.headlineMedium => t.headlineMedium,
        AppTextVariant.headlineSmall => t.headlineSmall,
        AppTextVariant.titleLarge => t.titleLarge,
        AppTextVariant.titleMedium => t.titleMedium,
        AppTextVariant.titleSmall => t.titleSmall,
        AppTextVariant.bodyLarge => t.bodyLarge,
        AppTextVariant.bodyMedium => t.bodyMedium,
        AppTextVariant.bodySmall => t.bodySmall,
        AppTextVariant.labelLarge => t.labelLarge,
        AppTextVariant.labelMedium => t.labelMedium,
        AppTextVariant.labelSmall => t.labelSmall,
      };

  @override
  Widget build(BuildContext context) {
    final style = _style(Theme.of(context).textTheme)?.copyWith(
      color: color,
      height: height,
      fontWeight: fontWeight,
      decoration: decoration,
      decorationColor: decorationColor,
      letterSpacing: letterSpacing,
    );
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      softWrap: softWrap,
    );
  }
}
