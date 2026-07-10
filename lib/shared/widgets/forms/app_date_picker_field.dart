import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../layout/app_text.dart';

class AppDatePickerField extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool isRequired;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const AppDatePickerField({
    super.key,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<AppDatePickerField> createState() => _AppDatePickerFieldState();
}

class _AppDatePickerFieldState extends State<AppDatePickerField> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    String daySuffix(int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    return '${date.day}${daySuffix(date.day)} ${months[date.month - 1]} ${date.year}';
  }

  void _showDatePicker() {
    DateTime tempPickedDate = _selectedDate ?? DateTime(1979, 8, 2);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const AppText.bodyMedium(
                        'Cancel',
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = tempPickedDate;
                        });
                        widget.onDateSelected(_selectedDate!);
                        Navigator.of(context).pop();
                      },
                      child: const AppText.bodyMedium(
                        'Done',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempPickedDate,
                  maximumDate: DateTime.now(),
                  minimumYear: 1900,
                  maximumYear: DateTime.now().year,
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText.labelLarge(
              widget.label,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6A7282), // Slate 700
            ),
            if (widget.isRequired)
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
        GestureDetector(
          onTap: _showDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.bodyLarge(
                  _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : (widget.hintText ?? ''),
                  color: _selectedDate != null
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF94A3B8),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
