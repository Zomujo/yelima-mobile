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
}
