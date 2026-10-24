import 'package:equatable/equatable.dart';

/// One medication's doses for a month and its adherence rate.
class MedicationHistoryEntity extends Equatable {
  final String medicationName;
  final num adherenceRate;
  final List<MedicationLogEntity> logs;

  const MedicationHistoryEntity({
    required this.medicationName,
    required this.adherenceRate,
    required this.logs,
  });

  /// Whether that day's doses were all taken, by day of month, for [month]'s logs only.
  Map<int, bool?> takenByDay(DateTime month) => {
        for (final log in logs)
          if (log.takenAt.year == month.year &&
              log.takenAt.month == month.month)
            log.takenAt.day: log.taken,
      };

  @override
  List<Object?> get props => [medicationName, adherenceRate, logs];
}

/// One day: all doses taken, a dose missed, or null while a dose can still be confirmed.
class MedicationLogEntity extends Equatable {
  final String id;
  final bool? taken;
  final DateTime takenAt;

  const MedicationLogEntity({
    required this.id,
    required this.taken,
    required this.takenAt,
  });

  @override
  List<Object?> get props => [id, taken, takenAt];
}
