/// The three daily dose times; each has its own list and reminder.
enum MedicationSection {
  morning(8),
  afternoon(13),
  evening(20);

  const MedicationSection(this.defaultHour);

  /// The dose hour used when no time is known.
  final int defaultHour;

  /// The name the server and the local table use, such as `MORNING`.
  String get key => name.toUpperCase();

  /// The section that is current at [hour] of the day.
  static MedicationSection at(int hour) =>
      hour < 12 ? morning : (hour < 17 ? afternoon : evening);
}
