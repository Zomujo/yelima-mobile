import 'package:flutter/widgets.dart';

import '../../../core/theme/app_motion.dart';

/// Cross-fades to a new [child] (a new [id], key or widget type) while easing
/// the size change; the first child shows without animating.
class FadeSwitch extends StatelessWidget {
  const FadeSwitch({
    super.key,
    required this.child,
    this.id,
    this.duration = AppMotion.medium,
    this.alignment = AlignmentDirectional.topStart,
    this.scaleFrom = 1,
  });

  final Widget child;

  /// What the child shows; a new value starts the cross-fade.
  final Object? id;
  final Duration duration;
  final AlignmentGeometry alignment;

  /// Size the incoming child grows from, as a fraction of normal.
  final double scaleFrom;

  @override
  Widget build(BuildContext context) {
    final duration =
        AppMotion.duration(context, this.duration);
    return AnimatedSize(
      duration: duration,
      curve: AppMotion.move,
      alignment: alignment,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        layoutBuilder: (current, previous) => Stack(
          alignment: alignment,
          // Children get the same constraints they would have alone.
          fit: StackFit.passthrough,
          children: [...previous, if (current != null) current],
        ),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: scaleFrom == 1
              ? child
              : ScaleTransition(
                  scale: Tween(begin: scaleFrom, end: 1.0).animate(animation),
                  child: child,
                ),
        ),
        child: id == null ? child : KeyedSubtree(key: ValueKey(id), child: child),
      ),
    );
  }
}
