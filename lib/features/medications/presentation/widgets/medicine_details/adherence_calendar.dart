import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../../core/utils/app_date_formats.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/entities/medication_history_entity.dart';
import 'package:clock/clock.dart';

/// A month of taken and missed doses, with a month picker.
class AdherenceCalendar extends StatefulWidget {
  final MedicationHistoryEntity history;

  /// Called with the first day of the month the user picks.
  final ValueChanged<DateTime> onMonthChanged;

  /// When the medicine started; earlier days and months aren't shown. Null when unknown.
  final DateTime? startDate;

  const AdherenceCalendar({
    super.key,
    required this.history,
    required this.onMonthChanged,
    this.startDate,
  });

  /// The months to pick from, newest first: back to [start]'s month, or 6 when unknown.
  static List<DateTime> monthsSince(DateTime? start, DateTime now) {
    final first = start == null
        ? DateTime(now.year, now.month - 5)
        : DateTime(start.year, start.month);
    return [
      for (var m = DateTime(now.year, now.month);
          !m.isBefore(first);
          m = DateTime(m.year, m.month - 1))
        m,
    ];
  }

  @override
  State<AdherenceCalendar> createState() => _AdherenceCalendarState();
}

class _AdherenceCalendarState extends State<AdherenceCalendar> {
  late DateTime _selectedMonth = DateTime(clock.now().year, clock.now().month);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = widget.startDate?.toLocal();
    final firstDay =
        start == null ? null : DateTime(start.year, start.month, start.day);
    final months = AdherenceCalendar.monthsSince(start, clock.now());
    final weekdays = [
      l10n.weekdaySun,
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThur,
      l10n.weekdayFri,
      l10n.weekdaySat,
    ];

    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final int firstWeekday =
        firstDayOfMonth.weekday % 7; // Sunday = 0, Monday = 1

    // Only this month's logs, so other months' days don't show here.
    final adherenceMap = widget.history.takenByDay(_selectedMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PopupMenuButton<DateTime>(
              enabled: months.length > 1,
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
                  widget.onMonthChanged(newValue);
                }
              },
              itemBuilder: (context) => months
                  .map((item) => PopupMenuItem<DateTime>(
                        value: item,
                        child: AppText.bodyMedium(
                          AppDateFormats.monthYear.format(item),
                          color: AppColors.slate800,
                        ),
                      ))
                  .toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.titleMedium(
                      AppDateFormats.monthYear.format(_selectedMonth),
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate800,
                    ),
                    if (months.length > 1) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.slate400,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // The server sends 0 when nothing is settled yet; that's no data, not 0 %.
            if (widget.history.logs.any((l) => l.taken != null))
              Row(
                children: [
                  AppText.labelMedium(
                    '${widget.history.adherenceRate.toStringAsFixed(0)}%',
                    fontWeight: FontWeight.bold,
                    color:
                        const Color(0xFFF59E0B), // Orange-ish adherence color
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
              return const SizedBox.shrink();
            }

            final day = index - firstWeekday + 1;
            final isTaken = adherenceMap[day];

            Color bgColor;
            Color textColor = Colors.white;

            // Only shade past and current days. Future days are unshaded if no data exists.
            final dayDate =
                DateTime(_selectedMonth.year, _selectedMonth.month, day);
            final now = clock.now();
            final isFuture = dayDate.isAfter(now);
            // Before the medicine started there was nothing to take or miss.
            final beforeStart = firstDay != null && dayDate.isBefore(firstDay);

            if (beforeStart) {
              bgColor = Colors.transparent;
              textColor = AppColors.slate300;
            } else if (isTaken == true) {
              bgColor = AppColors.emerald500; // Emerald 500
            } else if (isTaken == false && !isFuture) {
              bgColor = AppColors.slate300; // Slate 300
            } else {
              bgColor = Colors.transparent;
              textColor = AppColors.slate400; // Slate 400
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
        Row(
          children: [
            _buildLegendItem(AppColors.emerald500, l10n.taken),
            const SizedBox(width: 16),
            _buildLegendItem(AppColors.slate300, l10n.missed),
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
          color: AppColors.slate500,
        ),
      ],
    );
  }
}
