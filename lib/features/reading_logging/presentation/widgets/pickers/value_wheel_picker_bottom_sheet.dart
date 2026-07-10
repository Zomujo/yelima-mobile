import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../../shared/widgets/layout/app_button.dart';

class ValueWheelPickerBottomSheet extends StatefulWidget {
  final String title;
  final bool isDualPicker;

  // Single picker props
  final double initialValue;
  final double minValue;
  final double maxValue;
  final double step;
  final ValueChanged<double>? onSingleChanged;

  // Dual picker props (for BP)
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
  late double _currentSingle;
  late int _currentVal1;
  late int _currentVal2;

  late FixedExtentScrollController _singleController;
  late FixedExtentScrollController _dualController1;
  late FixedExtentScrollController _dualController2;

  final List<double> _singleOptions = [];
  final List<int> _dualOptions1 = [];
  final List<int> _dualOptions2 = [];

  @override
  void initState() {
    super.initState();
    if (widget.isDualPicker) {
      _currentVal1 = widget.initialValue1;
      _currentVal2 = widget.initialValue2;
      for (int i = widget.minValue1; i <= widget.maxValue1; i++) {
        _dualOptions1.add(i);
      }
      for (int i = widget.minValue2; i <= widget.maxValue2; i++) {
        _dualOptions2.add(i);
      }
      _dualController1 = FixedExtentScrollController(
          initialItem: _dualOptions1.indexOf(_currentVal1));
      _dualController2 = FixedExtentScrollController(
          initialItem: _dualOptions2.indexOf(_currentVal2));
    } else {
      _currentSingle = widget.initialValue;
      for (double i = widget.minValue; i <= widget.maxValue; i += widget.step) {
        // Fix floating point precision
        _singleOptions.add(double.parse(i.toStringAsFixed(1)));
      }

      // Ensure current value is in list, or find closest
      int initialIndex =
          _singleOptions.indexWhere((v) => (v - _currentSingle).abs() < 0.05);
      if (initialIndex == -1) initialIndex = 0;

      _singleController =
          FixedExtentScrollController(initialItem: initialIndex);
    }
  }

  @override
  void dispose() {
    if (widget.isDualPicker) {
      _dualController1.dispose();
      _dualController2.dispose();
    } else {
      _singleController.dispose();
    }
    super.dispose();
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
                color: const Color(0xFF1E293B),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child:
                widget.isDualPicker ? _buildDualPicker() : _buildSinglePicker(),
          ),
          const SizedBox(height: 32),
          AppButton(
            text: 'Confirm',
            onPressed: () {
              if (widget.isDualPicker) {
                widget.onDualChanged?.call(_currentVal1, _currentVal2);
              } else {
                widget.onSingleChanged?.call(_currentSingle);
              }
              Navigator.pop(context);
            },
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

  Widget _buildSinglePicker() {
    return CupertinoPicker(
      scrollController: _singleController,
      itemExtent: 48,
      onSelectedItemChanged: (index) {
        setState(() {
          _currentSingle = _singleOptions[index];
        });
      },
      children: _singleOptions.map((v) {
        return Center(
          child: AppText.displaySmall(
            v.toStringAsFixed(1),
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDualPicker() {
    return Row(
      children: [
        Expanded(
          child: CupertinoPicker(
            scrollController: _dualController1,
            itemExtent: 48,
            onSelectedItemChanged: (index) {
              setState(() {
                _currentVal1 = _dualOptions1[index];
              });
            },
            children: _dualOptions1.map((v) {
              return Center(
                child: AppText.displaySmall(
                  v.toString(),
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
        const AppText.displaySmall(
          '/',
          color: Colors.grey,
        ),
        Expanded(
          child: CupertinoPicker(
            scrollController: _dualController2,
            itemExtent: 48,
            onSelectedItemChanged: (index) {
              setState(() {
                _currentVal2 = _dualOptions2[index];
              });
            },
            children: _dualOptions2.map((v) {
              return Center(
                child: AppText.displaySmall(
                  v.toString(),
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
