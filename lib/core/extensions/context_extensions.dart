import 'package:flutter/material.dart';

import '../../shared/widgets/modals/app_modal.dart';

/// The one modal shown through [ContextExtensions.showModal], if any.
OverlayEntry? _currentModalOverlay;

/// Shows and hides the app's overlay modal (used where a dialog route won't do).
extension ContextExtensions on BuildContext {
  /// Shows [child] over everything, replacing any modal already open.
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

  /// Closes the modal opened with [showModal].
  void removeModal() {
    _currentModalOverlay?.remove();
    _currentModalOverlay = null;
  }
}
