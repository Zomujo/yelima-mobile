import 'package:flutter/material.dart';

enum AppButtonVariant { filled, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? outlineColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlineColor,
    this.fontSize,
    this.fontWeight,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
    this.padding,
  });

  bool get _isEffectivelyDisabled =>
      isDisabled || isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = backgroundColor ?? theme.primaryColor;
    final onPrimaryColor = foregroundColor ??
        (variant == AppButtonVariant.filled ? Colors.white : primaryColor);

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(onPrimaryColor),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (prefixIcon != null) ...[
          prefixIcon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 16,
                fontWeight: fontWeight ?? FontWeight.w600,
                color: onPrimaryColor,
              ),
            ),
          ),
        ),
        if (!isLoading && suffixIcon != null) ...[
          const SizedBox(width: 8),
          suffixIcon!,
        ],
      ],
    );

    ButtonStyle style;
    switch (variant) {
      case AppButtonVariant.filled:
        style = ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          disabledBackgroundColor: theme.disabledColor.withValues(alpha: 0.12),
          disabledForegroundColor: theme.disabledColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          elevation: 0,
          shadowColor: Colors.transparent,
        );
        break;
      case AppButtonVariant.outlined:
        style = OutlinedButton.styleFrom(
          foregroundColor: onPrimaryColor,
          disabledForegroundColor: theme.disabledColor,
          side: BorderSide(
            color: _isEffectivelyDisabled
                ? theme.disabledColor.withValues(alpha: 0.12)
                : (outlineColor ?? primaryColor),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        );
        break;
      case AppButtonVariant.text:
        style = TextButton.styleFrom(
          foregroundColor: onPrimaryColor,
          disabledForegroundColor: theme.disabledColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        );
        break;
    }

    Widget button;
    switch (variant) {
      case AppButtonVariant.filled:
        button = ElevatedButton(
          onPressed: _isEffectivelyDisabled ? null : onPressed,
          style: style,
          child: buttonContent,
        );
        break;
      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: _isEffectivelyDisabled ? null : onPressed,
          style: style,
          child: buttonContent,
        );
        break;
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: _isEffectivelyDisabled ? null : onPressed,
          style: style,
          child: buttonContent,
        );
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }
}
