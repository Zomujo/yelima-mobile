import 'package:flutter/material.dart';
import '../layout/app_text.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T> onChanged;
  final bool hasBorder;

  const AppDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<T>(
          initialValue: value,
          position: PopupMenuPosition.under,
          padding: EdgeInsets.zero,
          splashRadius: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
          ),
          onSelected: onChanged,
          itemBuilder: (context) => items
              .map(
                (item) => PopupMenuItem<T>(
                  value: item,
                  child: AppText.bodyMedium(
                    itemLabelBuilder(item),
                    color: const Color(0xFF1E293B),
                  ),
                ),
              )
              .toList(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasBorder ? const Color(0xFFE2E8F0) : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(16),
              color: hasBorder ? Colors.white : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.bodyMedium(
                  value != null ? itemLabelBuilder(value as T) : hintText,
                  color: value == null
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
