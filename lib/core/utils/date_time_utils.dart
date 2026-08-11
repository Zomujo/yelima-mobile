import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Derives a DateTime object for today given a 12-hour format time.
  static DateTime deriveTime(int hour, int minute, String period) {
    int h24 = hour;
    if (period.toUpperCase() == 'PM' && h24 < 12) {
      h24 += 12;
    } else if (period.toUpperCase() == 'AM' && h24 == 12) {
      h24 = 0;
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h24, minute);
  }

  /// Formats a date to strings like "Today", "Yesterday", "10th July 2026"
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      final day = date.day;
      final suffix = getDaySuffix(day);
      final monthYear = DateFormat('MMMM yyyy').format(date);
      return '$day$suffix $monthYear';
    }
  }

  /// Returns the ordinal suffix for a given day (st, nd, rd, th)
  static String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
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
}
