import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Android page transition: the new page fades in while sliding a little from
/// the right (or up, for forms opened as a sheet), and the old page drifts left.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.slow;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.reduced(context)) return child;
    final incoming = CurvedAnimation(
        parent: animation, curve: AppMotion.enter, reverseCurve: AppMotion.exit);
    final outgoing = CurvedAnimation(
        parent: secondaryAnimation, curve: AppMotion.move);
    final from = route.fullscreenDialog
        ? const Offset(0, 0.06)
        : const Offset(0.08, 0);
    return SlideTransition(
      position: Tween(begin: Offset.zero, end: const Offset(-0.04, 0))
          .animate(outgoing),
      // The fade ends halfway: a fading page is drawn off-screen first, which
      // is the costly part on older phones; the slide carries the rest.
      child: FadeTransition(
        opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.5, curve: AppMotion.enter),
            reverseCurve: const Interval(0.5, 1, curve: AppMotion.exit)),
        child: SlideTransition(
          position: Tween(begin: from, end: Offset.zero).animate(incoming),
          child: child,
        ),
      ),
    );
  }
}
