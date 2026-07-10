import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../layout/app_text.dart';

class AppFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool isRequired;
  final String? helperText;
  final TextEditingController? controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final int? maxLines;

  const AppFormField({
    super.key,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
    this.helperText,
    this.controller,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.onFieldSubmitted,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText.labelLarge(
              label,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6A7282), // Slate 700
            ),
            if (isRequired)
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  '*',
                  style: TextStyle(
                    color: Color(0xFFEF4444), // Red asterisk
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          validator: validator,
          autovalidateMode: autovalidateMode,
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate 400
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: const Color(0xFF94A3B8), // Slate 400
                    size: 20,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
                vertical: 16, horizontal: prefixIcon == null ? 16 : 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: AppText.labelMedium(
              helperText!,
              color: const Color(0xFF94A3B8),
            ),
          ),
      ],
    );
  }
}
