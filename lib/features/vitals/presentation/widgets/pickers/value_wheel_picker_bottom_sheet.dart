import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/shared/widgets/layout/app_button.dart';

import 'value_wheel.dart';

/// A bottom sheet with one or two scroll wheels for picking a reading.
class ValueWheelPickerBottomSheet extends StatefulWidget {
  final String title;
  final bool isDualPicker;

  final double initialValue;
  final double minValue;
  final double maxValue;
  final double step;
  final ValueChanged<double>? onSingleChanged;

  final int initialValue1;
  final int initialValue2;
  final int minValue1;
  final int maxValue1;
  final int minValue2;
  final int maxValue2;
  final void Function(int value1, int value2)? onDualChanged;

  const ValueWheelPickerBottomSheet.single({
    super.key,
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    this.step = 1.0,
    required this.onSingleChanged,
  })  : isDualPicker = false,
        initialValue1 = 0,
        initialValue2 = 0,
        minValue1 = 0,
        maxValue1 = 0,
        minValue2 = 0,
        maxValue2 = 0,
        onDualChanged = null;

  const ValueWheelPickerBottomSheet.dual({
    super.key,
    required this.title,
    required this.initialValue1,
    required this.initialValue2,
    required this.minValue1,
    required this.maxValue1,
    required this.minValue2,
    required this.maxValue2,
    required this.onDualChanged,
  })  : isDualPicker = true,
        initialValue = 0,
        minValue = 0,
        maxValue = 0,
        step = 1.0,
        onSingleChanged = null;

  static Future<void> showSingle(
    BuildContext context, {
    required String title,
    required double initialValue,
    required double minValue,
    required double maxValue,
    double step = 0.1,
    required ValueChanged<double> onChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      // Sized to its content: the default 9/16-of-screen cap cut off the button.
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ValueWheelPickerBottomSheet.single(
        title: title,
        initialValue: initialValue,
        minValue: minValue,
        maxValue: maxValue,
        step: step,
        onSingleChanged: onChanged,
      ),
    );
  }

  static Future<void> showDual(
    BuildContext context, {
    required String title,
    required int initialValue1,
    required int initialValue2,
    required int minValue1,
    required int maxValue1,
    required int minValue2,
    required int maxValue2,
    required void Function(int, int) onChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      // Sized to its content: the default 9/16-of-screen cap cut off the button.
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ValueWheelPickerBottomSheet.dual(
        title: title,
        initialValue1: initialValue1,
        initialValue2: initialValue2,
        minValue1: minValue1,
        maxValue1: maxValue1,
        minValue2: minValue2,
        maxValue2: maxValue2,
        onDualChanged: onChanged,
      ),
    );
  }

  @override
  State<ValueWheelPickerBottomSheet> createState() =>
      _ValueWheelPickerBottomSheetState();
}

class _ValueWheelPickerBottomSheetState
    extends State<ValueWheelPickerBottomSheet> {
  late double _single = widget.initialValue;
  late int _value1 = widget.initialValue1;
  late int _value2 = widget.initialValue2;

  /// The single wheel's steps, rounded to one decimal so 0.1 steps don't drift.
  late final List<double> _singleOptions = [
    for (var v = widget.minValue; v <= widget.maxValue; v += widget.step)
      double.parse(v.toStringAsFixed(1))
  ];

  static List<int> _range(int min, int max) =>
      [for (var i = min; i <= max; i++) i];

  void _confirm() {
    if (widget.isDualPicker) {
      widget.onDualChanged?.call(_value1, _value2);
    } else {
      widget.onSingleChanged?.call(_single);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.titleLarge(
                widget.title,
                fontWeight: FontWeight.bold,
                color: AppColors.slate800,
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close,
                    color: AppColors.slate400, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: widget.isDualPicker ? _dualWheels() : _singleWheel(),
          ),
          const SizedBox(height: 32),
          AppButton(
            text: context.l10n.confirm,
            onPressed: _confirm,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            borderRadius: 24,
            width: double.infinity,
            height: 50,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _singleWheel() => ValueWheel<double>(
        options: _singleOptions,
        initialIndex: _singleOptions
            .indexWhere((v) => (v - widget.initialValue).abs() < 0.05),
        label: (v) => v.toStringAsFixed(1),
        onChanged: (v) => _single = v,
      );

  Widget _dualWheels() {
    final first = _range(widget.minValue1, widget.maxValue1);
    final second = _range(widget.minValue2, widget.maxValue2);
    return Row(
      children: [
        Expanded(
          child: ValueWheel<int>(
            options: first,
            initialIndex: first.indexOf(widget.initialValue1),
            label: (v) => '$v',
            onChanged: (v) => _value1 = v,
          ),
        ),
        const AppText.displaySmall('/', color: Colors.grey),
        Expanded(
          child: ValueWheel<int>(
            options: second,
            initialIndex: second.indexOf(widget.initialValue2),
            label: (v) => '$v',
            onChanged: (v) => _value2 = v,
          ),
        ),
      ],
    );
  }
}
