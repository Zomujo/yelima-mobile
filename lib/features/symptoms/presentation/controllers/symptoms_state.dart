import 'package:equatable/equatable.dart';

import '../../domain/entities/symptom_entity.dart';

/// The reported symptoms; null until the phone's copy has loaded.
class SymptomsState extends Equatable {
  const SymptomsState({this.symptoms, this.refreshing = false});

  final List<SymptomEntity>? symptoms;

  /// True while the server's list is being fetched.
  final bool refreshing;

  bool get isLoading => symptoms == null || (symptoms!.isEmpty && refreshing);

  /// Symptoms grouped by the day they started, newest day first.
  List<(DateTime day, List<SymptomEntity> symptoms)> get byDay {
    final sorted = [...?symptoms]
      ..sort((a, b) => b.onsetDate.compareTo(a.onsetDate));
    final groups = <DateTime, List<SymptomEntity>>{};
    for (final s in sorted) {
      final d = s.onsetDate;
      groups.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(s);
    }
    return [for (final e in groups.entries) (e.key, e.value)];
  }

  SymptomsState copyWith({List<SymptomEntity>? symptoms, bool? refreshing}) =>
      SymptomsState(
          symptoms: symptoms ?? this.symptoms,
          refreshing: refreshing ?? this.refreshing);

  @override
  List<Object?> get props => [symptoms, refreshing];
}
