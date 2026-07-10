import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/entities/medication_history_entity.dart';
import '../../controllers/all_medicines_controller.dart';

class AdherenceCalendar extends StatefulWidget {
  final String medicationId;
  final MedicationHistoryEntity history;

  const AdherenceCalendar({
    super.key,
    required this.medicationId,
    required this.history,
  });

  @override
  State<AdherenceCalendar> createState() => _AdherenceCalendarState();
}

class _AdherenceCalendarState extends State<AdherenceCalendar> {
  late DateTime _selectedMonth;
  late List<DateTime> _recentMonths;

  @override
  void initState() {
    super.initState();
    _initMonths();
  }

  void _initMonths() {
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);

    // Generate last 6 months
    _recentMonths = List.generate(6, (index) {
      int month = now.month - index;
      int year = now.year;
      if (month <= 0) {
        month += 12;
        year -= 1;
      }
      return DateTime(year, month, 1);
    });

    // Try to match the history reference date if possible
    if (widget.history.logs.isNotEmpty) {
      final firstLog = widget.history.logs.first.takenAt;
      final historyMonth = DateTime(firstLog.year, firstLog.month, 1);
      if (_recentMonths.any((m) =>
          m.year == historyMonth.year && m.month == historyMonth.month)) {
        _selectedMonth = historyMonth;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat'];

    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final int firstWeekday =
        firstDayOfMonth.weekday % 7; // Sunday = 0, Monday = 1

    // Map data for O(1) lookup
    final adherenceMap = <int, bool>{};
    for (var log in widget.history.logs) {
      adherenceMap[log.takenAt.day] = log.taken;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PopupMenuButton<DateTime>(
              initialValue: _selectedMonth,
              position: PopupMenuPosition.under,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (DateTime? newValue) {
                if (newValue != null && newValue != _selectedMonth) {
                  setState(() {
                    _selectedMonth = newValue;
                  });
                  context.read<AllMedicinesController>().fetchMedicationHistory(
                        widget.medicationId,
                        targetMonth: newValue,
                      );
                }
              },
              itemBuilder: (context) => _recentMonths
                  .map((item) => PopupMenuItem<DateTime>(
                        value: item,
                        child: AppText.bodyMedium(
                          DateFormat('MMMM yyyy').format(item),
                          color: const Color(0xFF1E293B),
                        ),
                      ))
                  .toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.titleMedium(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                AppText.labelMedium(
                  '${widget.history.adherenceRate.toStringAsFixed(0)}%',
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF59E0B), // Orange-ish adherence color
                ),
                const SizedBox(width: 4),
                AppText.labelMedium(
                  'adherence',
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Days of week
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays
              .map((day) => AppText.labelSmall(
                    day,
                    color: Colors.grey.shade400,
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),

        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: daysInMonth + firstWeekday,
          itemBuilder: (context, index) {
            if (index < firstWeekday) {
              // Empty space for offset
              return const SizedBox.shrink();
            }

            final day = index - firstWeekday + 1;
            final isTaken = adherenceMap[day];

            Color bgColor;
            Color textColor = Colors.white;

            // Only shade past and current days. Future days are unshaded if no data exists.
            final dayDate =
                DateTime(_selectedMonth.year, _selectedMonth.month, day);
            final now = DateTime.now();
            final isFuture = dayDate.isAfter(now);

            if (isTaken == true) {
              bgColor = const Color(0xFF10B981); // Emerald 500
            } else if (isTaken == false && !isFuture) {
              bgColor = const Color(0xFFCBD5E1); // Slate 300
            } else {
              bgColor = Colors.transparent;
              textColor = const Color(0xFF94A3B8); // Slate 400
            }

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: AppText.labelMedium(
                  '$day',
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            );
          },
        ),
        // Legend
        Row(
          children: [
            _buildLegendItem(const Color(0xFF10B981), 'Taken'),
            const SizedBox(width: 16),
            _buildLegendItem(const Color(0xFFCBD5E1), 'Missed'),
          ],
        )
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        AppText.labelSmall(
          label,
          color: const Color(0xFF64748B), // Slate 500
        ),
      ],
    );
  }
}
