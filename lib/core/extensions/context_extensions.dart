import 'package:flutter/material.dart';
import '../../shared/widgets/modals/app_modal.dart';

/// Global variable to track current overlay for general modals
OverlayEntry? _currentModalOverlay;

extension ContextExtensions on BuildContext {
  // --- Navigation Helpers (GoRouter) ---
  // void push(String location, {Object? extra}) => GoRouter.of(this).push(location, extra: extra);
  // void go(String location, {Object? extra}) => GoRouter.of(this).go(location, extra: extra);
  // void pop() => GoRouter.of(this).pop();

  // --- Snackbar Helpers ---
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.redAccent);
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }

  void showInfoSnackBar(String message) {
    showSnackBar(message, backgroundColor: Theme.of(this).primaryColor);
  }

  // --- Overlay Modal Helpers ---
  void showModal({
    required Widget child,
    bool isDismissible = true,
    Duration? animationDuration,
    ModalAlignment? alignment,
  }) {
    removeModal();

    _currentModalOverlay = OverlayEntry(
      builder: (context) => OverlayModal(
        isDismissible: isDismissible,
        animationDuration:
            animationDuration ?? const Duration(milliseconds: 300),
        onDismiss: removeModal,
        alignment: alignment ?? ModalAlignment.center,
        child: child,
      ),
    );

    Overlay.of(this, rootOverlay: true).insert(_currentModalOverlay!);
  }

  void removeModal() {
    if (_currentModalOverlay != null) {
      _currentModalOverlay!.remove();
      _currentModalOverlay = null;
    }
  }

  bool get hasActiveModal => _currentModalOverlay != null;

  // --- Theme & Size Helpers ---
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.of(this).size;
}
