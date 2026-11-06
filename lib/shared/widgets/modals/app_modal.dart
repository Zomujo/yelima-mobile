import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';

export 'modal_container.dart';

/// Where an overlay modal sits.
enum ModalAlignment {
  center,
  bottomCenter,
}

/// Dims the screen and animates a modal in.
class OverlayModal extends StatefulWidget {
  final Widget child;
  final bool isDismissible;
  final Duration animationDuration;
  final VoidCallback onDismiss;
  final ModalAlignment alignment;

  /// Asked before a tap outside or Back closes the modal; false keeps it open.
  final Future<bool> Function()? confirmDismiss;

  const OverlayModal({
    super.key,
    required this.child,
    required this.isDismissible,
    this.animationDuration = AppMotion.medium,
    required this.onDismiss,
    this.alignment = ModalAlignment.center,
    this.confirmDismiss,
  });

  @override
  State<OverlayModal> createState() => _OverlayModalState();
}

class _OverlayModalState extends State<OverlayModal>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(duration: widget.animationDuration, vsync: this);
  late final _progress = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.enter,
      reverseCurve: AppMotion.exit);
  late final _scale = Tween(begin: 0.95, end: 1.0).animate(_progress);
  late final _slide =
      Tween(begin: const Offset(0, 1), end: Offset.zero).animate(_progress);
  bool _shown = false;
  bool _isDismissing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;
    _shown = true;
    // With animations off, open in the end state at once.
    AppMotion.reduced(context) ? _controller.value = 1 : _controller.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    if (_isDismissing) return;
    _isDismissing =
        true; // also while asking, so a second tap doesn't ask twice
    final keep = await widget.confirmDismiss?.call() == false;
    if (!mounted) return;
    setState(() => _isDismissing = !keep);
    if (keep) return;
    if (!AppMotion.reduced(context)) await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = widget.alignment == ModalAlignment.bottomCenter;
    final faded = FadeTransition(opacity: _progress, child: widget.child);
    return RepaintBoundary(
      child: BackButtonListener(
        onBackButtonPressed: () async {
          if (widget.isDismissible) _dismiss();
          return true; // Consume the back button event while modal is active
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.isDismissible ? _dismiss : null,
                child: _Barrier(progress: _progress),
              ),
            ),
            AnimatedPadding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              duration: AppMotion.quick,
              curve: AppMotion.enter,
              child: Align(
                alignment: bottom ? Alignment.bottomCenter : Alignment.center,
                child: bottom
                    ? SlideTransition(position: _slide, child: faded)
                    : ScaleTransition(scale: _scale, child: faded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The dimmed backdrop, fading in with [progress].
///
/// No blur: re-blurring the whole screen every frame (while the modal moves
/// or the keyboard opens) made older phones drop frames.
class _Barrier extends AnimatedWidget {
  const _Barrier({required Animation<double> progress})
      : super(listenable: progress);

  @override
  Widget build(BuildContext context) => ColoredBox(
      color: Colors.black
          .withValues(alpha: 0.55 * (listenable as Animation<double>).value));
}

/// Shows [child] as a dialog over a clear barrier; tapping outside returns [dismissValue].
Future<T?> showAppDialog<T>(BuildContext context, Widget child,
        {T? dismissValue, Color barrierColor = Colors.transparent}) =>
    showDialog<T>(
      context: context,
      barrierColor: barrierColor,
      useSafeArea: false,
      builder: (context) => OverlayModal(
        isDismissible: true,
        onDismiss: () => Navigator.of(context).pop(dismissValue),
        child: child,
      ),
    );
