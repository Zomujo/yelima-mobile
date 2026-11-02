import 'entities/medication_adherence.dart';

/// The server's weekly adherence rule, worked out on the phone when the server
/// can't answer: a dot per day of this Monday-to-Sunday week, and the rate over
/// today and the 6 days before, counting only days that are decided.
abstract final class WeekAdherence {
  /// Builds the week from the days the server sent before ([saved]) and
  /// today's doses on the phone. [perDay] is how many doses a day the
  /// current schedules plan, for the days still to come.
  static MedicationAdherence compute({
    required List<AdherenceDay> saved,
    required int scheduledToday,
    required int takenToday,
    required int perDay,
    required DateTime now,
  }) {
    final today = _date(now);
    final byDate = {for (final d in saved) _date(d.takenAt): d};

    AdherenceDay dayOn(DateTime date) {
      if (date == today) {
        final done = scheduledToday > 0 && takenToday >= scheduledToday;
        return AdherenceDay(
            takenAt: date,
            taken: done ? true : null,
            takenDoses: takenToday,
            scheduledDoses: scheduledToday);
      }
      if (date.isAfter(today)) {
        return AdherenceDay(
            takenAt: date, taken: null, takenDoses: 0, scheduledDoses: perDay);
      }
      final day = byDate[date];
      final planned = day?.scheduledDoses;
      // Never seen here: no data, like the server's null.
      if (day == null || planned == null) {
        return AdherenceDay(takenAt: date, taken: null);
      }
      // A day that is over is decided; a day with nothing planned isn't a miss.
      final taken = (day.takenDoses ?? 0).clamp(0, planned);
      return AdherenceDay(
          id: day.id,
          takenAt: date,
          taken: day.taken ?? (planned > 0 && taken >= planned),
          takenDoses: taken,
          scheduledDoses: planned);
    }

    var taken = 0, planned = 0;
    for (var i = 0; i < 7; i++) {
      final d = dayOn(_addDays(today, -i));
      if (d.taken == null) continue;
      taken += d.takenDoses ?? 0;
      planned += d.scheduledDoses ?? 0;
    }
    final monday = mondayOf(now);
    return MedicationAdherence(
      rate: planned == 0 ? 0 : (100 * taken / planned).roundToDouble(),
      days: [for (var i = 0; i < 7; i++) dayOn(_addDays(monday, i))],
    );
  }

  /// Midnight on the Monday of [now]'s week.
  static DateTime mondayOf(DateTime now) =>
      _addDays(_date(now), 1 - now.weekday);

  static DateTime _date(DateTime t) => DateTime(t.year, t.month, t.day);

  static DateTime _addDays(DateTime day, int n) =>
      DateTime(day.year, day.month, day.day + n);
}
