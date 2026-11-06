import 'package:flutter/material.dart';
import 'package:yelima/core/theme/app_colors.dart';

/// The card a modal's content sits in.
class ModalContainer extends StatelessWidget {
  final Widget? child;
  final String? title;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final bool isBottomSheet;
  final Color? backgroundColor;

  const ModalContainer({
    super.key,
    this.child,
    this.title,
    this.width,
    this.height,
    this.padding,
    this.showCloseButton = true,
    this.onClose,
    this.isBottomSheet = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width ??
            (isBottomSheet
                ? double.infinity
                : MediaQuery.of(context).size.width * 0.85),
        height: height,
        margin: isBottomSheet ? EdgeInsets.zero : const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: isBottomSheet
              ? const BorderRadius.vertical(top: Radius.circular(32))
              : BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: isBottomSheet,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null || showCloseButton)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (title != null)
                        Expanded(
                          child: Text(
                            title!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily:
                                  'ProductSans', // using standard app font
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      if (showCloseButton)
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.slate100,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                size: 20, color: AppColors.slate500),
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            onPressed:
                                onClose ?? () => Navigator.of(context).pop(),
                          ),
                        ),
                    ],
                  ),
                if ((title != null || showCloseButton) && child != null)
                  const SizedBox(height: 16),
                if (child != null) child!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
