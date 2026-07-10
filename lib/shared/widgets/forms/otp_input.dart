import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  final Function(String) onCompleted;
  final Function(String)? onChange;
  final int length;

  const OtpInput({
    super.key,
    required this.onCompleted,
    this.onChange,
    this.length = 4,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (index) => TextEditingController());
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    String otp = '';
    for (var controller in _controllers) {
      otp += controller.text;
    }

    // Call onChange callback with current value
    widget.onChange?.call(otp);

    // Call onCompleted only when all fields are filled
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSixDigit = widget.length > 5;
    final boxSize = isSixDigit ? 48.0 : 60.0;
    final fontSize = isSixDigit ? 20.0 : 24.0;
    final borderRadius = isSixDigit ? 12.0 : 15.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: theme.dividerColor,
              width: 1.3,
            ),
            color: theme.cardColor,
          ),
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            cursorColor: theme.primaryColor,
            style: TextStyle(fontSize: fontSize),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) => _onChanged(value, index),
            onFieldSubmitted: (_) {
              if (index < widget.length - 1) {
                _focusNodes[index + 1].requestFocus();
              }
            },
            onEditingComplete: () {},
          ),
        );
      }),
    );
  }

  void clearOtp() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  String getCurrentOtp() {
    String otp = '';
    for (var controller in _controllers) {
      otp += controller.text;
    }
    return otp;
  }
}
