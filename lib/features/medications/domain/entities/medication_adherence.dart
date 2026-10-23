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

/// Whether the doses of one day were taken.
class AdherenceDay extends Equatable {
  final String? id;
  final bool taken;
  final DateTime takenAt;

  const AdherenceDay({
    this.id,
    required this.taken,
    required this.takenAt,
  });

  @override
  List<Object?> get props => [id, taken, takenAt];
}
