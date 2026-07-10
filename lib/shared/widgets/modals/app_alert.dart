import 'package:flutter/material.dart';

class AppAlert extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? confirmColor;
  final Color? cancelColor;

  const AppAlert({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.confirmColor,
    this.cancelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: backgroundColor ?? theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: icon,
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: textColor ?? colorScheme.onSurface,
        ),
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor?.withValues(alpha: 0.8) ??
              colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: cancelColor ?? colorScheme.onSurface,
            ),
            child: Text(cancelText!),
          ),
        if (confirmText != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ??
                  (isDestructive ? colorScheme.error : colorScheme.primary),
            ),
            child: Text(confirmText!),
          ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    Widget? icon,
    Color? backgroundColor,
    Color? textColor,
    Color? confirmColor,
    Color? cancelColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppAlert(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
      ),
    );
  }

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    Widget? icon,
  }) {
    return show(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: isDestructive,
      icon: icon,
    );
  }

  static Future<bool?> delete(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: true,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.red,
        size: 32,
      ),
    );
  }
}
