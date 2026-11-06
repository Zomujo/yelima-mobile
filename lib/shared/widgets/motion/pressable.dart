import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/widgets.dart';

import '../../../core/theme/app_motion.dart';

/// Shrinks [child] slightly while a finger is on it, so taps feel physical.
///
/// Only listens to the pointer; the child keeps handling the tap itself.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.scale = 0.97});

  final Widget child;

  /// Size while pressed, as a fraction of normal.
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  Offset? _downAt;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final pressed = _down && !AppMotion.reduced(context);
    return Listener(
      onPointerDown: (e) {
        _downAt = e.position;
        _set(true);
      },
      // A finger that starts moving is scrolling, not pressing.
      onPointerMove: (e) {
        final from = _downAt;
        if (from != null && (e.position - from).distance > kTouchSlop) {
          _set(false);
        }
      },
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: pressed ? widget.scale : 1,
        duration: AppMotion.quick,
        curve: AppMotion.move,
        child: widget.child,
      ),
    );
  }
}
