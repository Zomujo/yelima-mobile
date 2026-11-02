import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';

/// The adherence rate and the days it covers.
class MedicationAdherence extends Equatable {
  final double rate;
  final List<AdherenceDay> days;

  /// When the phone saved these numbers; null for the server's own answer.
  final DateTime? savedAt;

  const MedicationAdherence({
    required this.rate,
    required this.days,
    this.savedAt,
  });

  /// Saved today. An older copy covers a different 7 days.
  bool get isCurrent {
    final saved = savedAt, now = clock.now();
    return saved != null &&
        saved.year == now.year &&
        saved.month == now.month &&
        saved.day == now.day;
  }

  @override
  List<Object?> get props => [rate, days, savedAt];
}

/// One day of the week: whether all its doses were taken, and how many.
class AdherenceDay extends Equatable {
  final String? id;

  /// True when every dose was taken, false once a dose was missed,
  /// null while a dose can still be confirmed (up to 48 h) or the day is ahead.
  final bool? taken;
  final DateTime takenAt;
  final int? takenDoses;
  final int? scheduledDoses;

  const AdherenceDay({
    this.id,
    required this.taken,
    required this.takenAt,
    this.takenDoses,
    this.scheduledDoses,
  });

  @override
  List<Object?> get props => [id, taken, takenAt, takenDoses, scheduledDoses];
}
