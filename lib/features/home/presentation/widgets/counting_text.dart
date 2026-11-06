import 'package:flutter/widgets.dart';

import '../../../../shared/widgets/motion/count_up.dart';

/// Counts up the number in [text] ("126", "/77", "5.9"), keeping its prefix
/// and decimals; text without a number, like "--", is shown as is.
class CountingText extends StatelessWidget {
  const CountingText(
    this.text, {
    super.key,
    required this.playOnce,
    required this.builder,
  });

  final String text;

  /// Counts from zero only the first time this key is shown.
  final String playOnce;

  /// Draws the text at each step.
  final Widget Function(String text) builder;

  static final _number = RegExp(r'^(\D*)(\d+(?:\.(\d+))?)$');

  @override
  Widget build(BuildContext context) {
    final match = _number.firstMatch(text);
    if (match == null) return builder(text);
    final target = double.parse(match[2]!);
    final decimals = match[3]?.length ?? 0;
    return CountUp(
      value: target,
      playOnce: playOnce,
      // Lands on the original text, so the final reading is exactly as given.
      builder: (_, v) => builder(
          v == target ? text : '${match[1]}${v.toStringAsFixed(decimals)}'),
    );
  }
}
