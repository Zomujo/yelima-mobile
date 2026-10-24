import 'package:flutter/cupertino.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';

/// One scroll wheel over [options], starting at [initialIndex].
class ValueWheel<T> extends StatefulWidget {
  const ValueWheel({
    super.key,
    required this.options,
    required this.initialIndex,
    required this.label,
    required this.onChanged,
  });

  final List<T> options;
  final int initialIndex;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  @override
  State<ValueWheel<T>> createState() => _ValueWheelState<T>();
}

class _ValueWheelState<T> extends State<ValueWheel<T>> {
  late final _controller = FixedExtentScrollController(
      initialItem: widget.initialIndex.clamp(0, widget.options.length - 1));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CupertinoPicker(
        scrollController: _controller,
        itemExtent: 48,
        onSelectedItemChanged: (i) => widget.onChanged(widget.options[i]),
        children: [
          for (final v in widget.options)
            Center(
              child: AppText.displaySmall(widget.label(v),
                  color: AppColors.slate800, fontWeight: FontWeight.w600),
            ),
        ],
      );
}
