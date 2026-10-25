import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../layout/app_text.dart';

/// The app's text field: label above, optional required star, helper text below.
/// With [isPassword] it hides the text and adds a show/hide button.
class AppFormField extends StatefulWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.isRequired = false,
    this.helperText,
    this.controller,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
  });

  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool isRequired;
  final String? helperText;
  final TextEditingController? controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  late bool _hidden = widget.isPassword;

  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText.labelLarge(w.label,
                fontWeight: FontWeight.w400, color: const Color(0xFF6A7282)),
            if (w.isRequired)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('*',
                    style: TextStyle(
                        color: AppColors.red500,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: w.controller,
          focusNode: w.focusNode,
          onFieldSubmitted: w.onFieldSubmitted,
          onChanged: w.onChanged,
          enabled: w.enabled,
          obscureText: _hidden,
          obscuringCharacter: '*',
          keyboardType: w.keyboardType,
          textInputAction: w.textInputAction,
          maxLines: w.isPassword ? 1 : w.maxLines,
          maxLength: w.maxLength,
          inputFormatters: w.inputFormatters,
          textCapitalization: w.textCapitalization,
          validator: w.validator,
          autovalidateMode: w.autovalidateMode,
          style: TextStyle(
              color: w.enabled ? AppColors.slate800 : AppColors.slate400,
              fontSize: 16),
          decoration: InputDecoration(
            hintText: w.hintText,
            hintStyle: const TextStyle(color: AppColors.slate400),
            prefixIcon: w.prefixWidget ??
                (w.prefixIcon == null
                    ? null
                    : Icon(w.prefixIcon, color: AppColors.slate400, size: 20)),
            suffixIcon: w.isPassword
                ? IconButton(
                    icon: Icon(
                        _hidden ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.slate400,
                        size: 20),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : w.suffixIcon,
            filled: true,
            fillColor: w.enabled ? Colors.white : AppColors.slate100,
            contentPadding: EdgeInsets.symmetric(
                vertical: 16, horizontal: w.prefixIcon == null ? 16 : 0),
            border: _border(AppColors.slate200),
            enabledBorder: _border(AppColors.slate200),
            disabledBorder: _border(const Color(0x45B7B3B3)),
            focusedBorder: _border(AppColors.primaryGreen, 2),
          ),
        ),
        if (w.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child:
                AppText.labelMedium(w.helperText!, color: AppColors.slate400),
          ),
      ],
    );
  }
}
