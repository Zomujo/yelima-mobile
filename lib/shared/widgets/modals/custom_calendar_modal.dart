import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../layout/app_text.dart';
import '../layout/app_button.dart';

class CustomCalendarModal extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomCalendarModal({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  static Future<DateTime?> show(BuildContext context, DateTime initialDate) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => CustomCalendarModal(
        initialDate: initialDate,
        onDateSelected: (date) => Navigator.of(context).pop(date),
      ),
    );
  }

  @override
  State<CustomCalendarModal> createState() => _CustomCalendarModalState();
}

class _CustomCalendarModalState extends State<CustomCalendarModal> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    // Padding for previous month
    final prevMonthDaysCount = firstDay.weekday - 1; // 1 = Monday
    final days = <DateTime>[];

    for (int i = prevMonthDaysCount; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    // Current month days
    for (int i = 0; i < lastDay.day; i++) {
      days.add(firstDay.add(Duration(days: i)));
    }

    // Padding for next month
    final remainingDays = 42 - days.length; // 6 rows of 7
    for (int i = 1; i <= remainingDays; i++) {
      days.add(lastDay.add(Duration(days: i)));
    }

    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthName(int month) {
    const months = [
      '',
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
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText.headlineSmall(
                'Select Date',
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Month Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _previousMonth,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.chevron_left, color: Color(0xFF475569)),
                ),
              ),
              AppText.bodyLarge(
                '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.chevron_right, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekdays
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays
                .map((day) => Expanded(
                      child: Center(
                        child: AppText.labelMedium(
                          day,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final date = days[index];
              final isCurrentMonth = date.month == _currentMonth.month;
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () {
                  if (date.isAfter(DateTime.now())) {
                    return;
                  }
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? Colors.orange.shade50
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppText.bodyMedium(
                      '${date.day}',
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : isCurrentMonth
                              ? date.isAfter(DateTime.now())
                                  ? Colors.grey.shade300
                                  : const Color(0xFF1E293B)
                              : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Apply Button
          AppButton(
            text: 'Apply',
            onPressed: () => widget.onDateSelected(_selectedDate),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            borderRadius: 24,
            height: 50,
          ),
          const SizedBox(height: 16), // Bottom safe area padding
        ],
      ),
    );
  }
}
