import 'package:flutter/material.dart';

class GlobalAsyncLoader extends StatelessWidget {
  final String? message;
  
  const GlobalAsyncLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissing by back button
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: ColoredBox(
                color: const Color(0xB0000000), // Semi-transparent black
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
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
                          message ?? 'Please wait...',
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

  /// Helper to show loader as an overlay via an OverlayEntry
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {String? message}) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => GlobalAsyncLoader(message: message),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
