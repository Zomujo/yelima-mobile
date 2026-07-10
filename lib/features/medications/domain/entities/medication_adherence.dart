import 'package:equatable/equatable.dart';

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
