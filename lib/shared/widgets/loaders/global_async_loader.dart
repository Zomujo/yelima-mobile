import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';

/// A full-screen loader with a message, shown over everything.
class GlobalAsyncLoader extends StatelessWidget {
  final String? message;

  const GlobalAsyncLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: ColoredBox(
                color: const Color(0xB0000000),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 25),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 20),
                        Text(
                          message ?? context.l10n.loading,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static OverlayEntry? _overlayEntry;
  static OverlayState? _overlay;

  /// Shows the loader over the whole app, once.
  static void show(BuildContext context, {String? message}) {
    if (_overlayEntry != null) return;
    // The root navigator's overlay outlives tab and modal navigators, and works
    // even when [context] is the navigator itself.
    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    if (overlay == null) return;
    _overlay = overlay;
    _overlayEntry =
        OverlayEntry(builder: (_) => GlobalAsyncLoader(message: message));
    overlay.insert(_overlayEntry!);
  }

  /// Removes the loader if it is showing.
  static void hide() {
    // If the overlay itself was torn down, the entry went with it.
    if (_overlay?.mounted ?? false) _overlayEntry?.remove();
    _overlayEntry = null;
    _overlay = null;
  }
}
