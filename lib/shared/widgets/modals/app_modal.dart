import 'dart:ui';
import 'package:flutter/material.dart';

enum ModalAlignment {
  center,
  bottomCenter,
}

class OverlayModal extends StatefulWidget {
  final Widget child;
  final bool isDismissible;
  final Duration animationDuration;
  final VoidCallback onDismiss;
  final ModalAlignment alignment;

  const OverlayModal({
    super.key,
    required this.child,
    required this.isDismissible,
    required this.animationDuration,
    required this.onDismiss,
    this.alignment = ModalAlignment.center,
  });

  @override
  State<OverlayModal> createState() => _OverlayModalState();
}

class _OverlayModalState extends State<OverlayModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.alignment == ModalAlignment.bottomCenter
          ? const Offset(0, 1)
          : Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.isDismissible ? _dismiss : null,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black
                        .withValues(alpha: 0.5 * _fadeAnimation.value),
                  ),
                ),
              ),
            ),
            AnimatedPadding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Align(
                alignment: widget.alignment == ModalAlignment.bottomCenter
                    ? Alignment.bottomCenter
                    : Alignment.center,
                child: _buildModalContent(),
              ),
            ),
          ],
        );
      },
    ),
    );
  }

  Widget _buildModalContent() {
    if (widget.alignment == ModalAlignment.bottomCenter) {
      return SlideTransition(
        position: _slideAnimation,
        child: Opacity(opacity: _fadeAnimation.value, child: widget.child),
      );
    } else {
      return Transform.scale(
        scale: _scaleAnimation.value,
        child: Opacity(opacity: _fadeAnimation.value, child: widget.child),
      );
    }
  }
}

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
                            color: Color(0xFFF1F5F9), // Slate 100
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                size: 20, color: Color(0xFF64748B)),
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
