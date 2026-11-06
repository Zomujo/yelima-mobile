import 'package:flutter/widgets.dart';

import '../../../core/theme/app_motion.dart';

/// Counts a number up from zero when it first shows, and from the old value
/// to the new one when it changes. [builder] draws the number at each step.
class CountUp extends StatefulWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.builder,
    this.playOnce,
  });

  final double value;
  final Widget Function(BuildContext context, double value) builder;

  /// When set, counts from zero only the first time this key is shown.
  final String? playOnce;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> {
  double? _from;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final key = widget.playOnce;
    final count = !AppMotion.reduced(context) &&
        (key == null || AppMotion.firstTime(key));
    _from ??= count ? 0 : widget.value;
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return widget.builder(context, widget.value);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _from, end: widget.value),
      duration: const Duration(milliseconds: 700),
      curve: AppMotion.enter,
      builder: (context, value, _) => widget.builder(context, value),
    );
  }
}
