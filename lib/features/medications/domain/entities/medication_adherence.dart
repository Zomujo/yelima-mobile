import 'package:equatable/equatable.dart';

/// The adherence rate and the days it covers.
class MedicationAdherence extends Equatable {
  final double rate;
  final List<AdherenceDay> days;

  const MedicationAdherence({
    required this.rate,
    required this.days,
  });

  @override
  List<Object?> get props => [rate, days];
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
