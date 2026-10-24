/// When a dose can be confirmed: from its exact time until the end of that day.
/// After midnight it is missed, and the next day starts fresh.
abstract final class DoseWindow {
  /// Today's occurrence of a dose scheduled at [time]'s hour and minute.
  static DateTime scheduledToday(DateTime time, DateTime now) =>
      DateTime(now.year, now.month, now.day, time.hour, time.minute);

  /// Whether the dose can be confirmed [now] (never before its time).
  static bool canConfirm(DateTime time, DateTime now) =>
      !now.isBefore(scheduledToday(time, now));

  /// Whether a dose confirmed on [takenOn] counts as taken on [now]'s day.
  static bool takenToday(DateTime? takenOn, DateTime now) =>
      takenOn != null &&
      takenOn.year == now.year &&
      takenOn.month == now.month &&
      takenOn.day == now.day;
}
