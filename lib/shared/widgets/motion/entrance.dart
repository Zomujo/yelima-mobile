import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_motion.dart';

/// Fades [child] in while it rises a little, after a delay set by [index],
/// so a list of them arrives one after another.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.index = 0,
    this.rise = 16,
    this.playOnce,
    this.enabled = true,
  });

  final Widget child;

  /// False shows the child straight away, e.g. for rows built by scrolling.
  final bool enabled;

  /// Position in a staggered group; later items start later.
  final int index;

  /// How far, in pixels, the child rises into place.
  final double rise;

  /// When set, plays only the first time this key is shown while the app runs.
  final String? playOnce;

  /// Wraps each of [children] in an [Entrance], staggered in order.
  static List<Widget> staggered(List<Widget> children,
          {String? playOnce, int startAt = 0}) =>
      [
        for (final (i, child) in children.indexed)
          Entrance(
            index: startAt + i,
            playOnce: playOnce == null ? null : '$playOnce/$i',
            child: child,
          ),
      ];

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> {
  // Never more than this many steps of delay, so long lists don't drag.
  static const _maxSteps = 8;
  bool? _animate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final key = widget.playOnce;
    _animate ??= widget.enabled &&
        !AppMotion.reduced(context) &&
        (key == null || AppMotion.firstTime(key));
  }

  @override
  Widget build(BuildContext context) {
    if (_animate != true) return widget.child;
    final delay = AppMotion.stagger * widget.index.clamp(0, _maxSteps);
    // Delay inside the effects (not Animate's own delay, which starts a timer
    // that outlives the widget in tests).
    return widget.child
        .animate()
        // A shorter fade than rise: a fading widget is drawn off-screen first,
        // so the less time it spends fading, the cheaper each frame.
        .fadeIn(delay: delay, duration: AppMotion.medium, curve: AppMotion.enter)
        .moveY(
            delay: delay,
            begin: widget.rise,
            end: 0,
            duration: AppMotion.slow,
            curve: AppMotion.enter);
  }
}
