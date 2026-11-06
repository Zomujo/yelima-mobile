import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_motion.dart';

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
  static GlobalKey<_FadeInOutState>? _fade;

  /// Shows the loader over the whole app, once.
  static void show(BuildContext context, {String? message}) {
    if (_overlayEntry != null) return;
    // The root navigator's overlay outlives tab and modal navigators, and works
    // even when [context] is the navigator itself.
    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    if (overlay == null) return;
    final fade = GlobalKey<_FadeInOutState>();
    _overlay = overlay;
    _fade = fade;
    _overlayEntry = OverlayEntry(
        builder: (_) =>
            _FadeInOut(key: fade, child: GlobalAsyncLoader(message: message)));
    overlay.insert(_overlayEntry!);
  }

  /// Fades the loader out and removes it, if it is showing.
  static void hide() {
    final entry = _overlayEntry;
    final fade = _fade?.currentState;
    // If the overlay itself was torn down, the entry went with it.
    final mounted = _overlay?.mounted ?? false;
    _overlayEntry = null;
    _overlay = null;
    _fade = null;
    if (entry == null || !mounted) return;
    fade == null ? entry.remove() : fade.fadeOut(entry.remove);
  }
}

/// Fades the loader in when it appears, and out before it goes.
class _FadeInOut extends StatefulWidget {
  const _FadeInOut({super.key, required this.child});

  final Widget child;

  @override
  State<_FadeInOut> createState() => _FadeInOutState();
}

class _FadeInOutState extends State<_FadeInOut>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(vsync: this, duration: AppMotion.quick);
  bool _leaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed && !_leaving) {
      AppMotion.reduced(context)
          ? _controller.value = 1
          : _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Fades out, then calls [done]; taps go through to the app meanwhile.
  void fadeOut(VoidCallback done) {
    if (AppMotion.reduced(context)) return done();
    setState(() => _leaving = true);
    _controller.reverse().then((_) => done());
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        ignoring: _leaving,
        child: FadeTransition(opacity: _controller, child: widget.child),
      );
}
