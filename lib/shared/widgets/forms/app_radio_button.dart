import 'package:flutter/material.dart';

enum RadioButtonType {
  filled,
  iconCentered,
}

class AppRadioButton<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String text;
  final RadioButtonType type;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? borderColor;
  final Color? textColor;
  final double radioSize;
  final double borderWidth;
  final FontWeight? fontWeight;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final bool enabled;
  final VoidCallback? onTap;

  const AppRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.text,
    this.type = RadioButtonType.iconCentered,
    this.activeColor,
    this.inactiveColor,
    this.borderColor,
    this.textColor,
    this.radioSize = 20.0,
    this.borderWidth = 1.5,
    this.fontWeight,
    this.fontSize,
    this.padding,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8.0,
    this.enabled = true,
    this.onTap,
  });

  bool get isSelected {
    return value == groupValue;
  }

  void _handleTap() {
    if (enabled) {
      if (onChanged != null) {
        onChanged!(value);
      }
    }
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final computedActiveColor = activeColor ?? theme.primaryColor;
    final computedInactiveColor =
        inactiveColor ?? theme.disabledColor.withValues(alpha: 0.2);
    final computedBorderColor =
        borderColor ?? (isSelected ? computedActiveColor : theme.disabledColor);
    final computedTextColor = textColor ??
        (enabled ? theme.textTheme.bodyLarge?.color : theme.disabledColor);

    return GestureDetector(
      onTap: _handleTap,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: radioSize,
              height: radioSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : computedInactiveColor,
                border: Border.all(
                  color: computedBorderColor,
                  width: borderWidth,
                ),
              ),
              child: isSelected && type == RadioButtonType.iconCentered
                  ? Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: CircleAvatar(
                        backgroundColor: computedActiveColor,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: spacing),
            Text(
              text,
              style: TextStyle(
                color: computedTextColor,
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppRadioOption<T> {
  final T value;
  final String text;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final bool? enabled;

  const AppRadioOption({
    required this.value,
    required this.text,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.enabled,
  });
}
