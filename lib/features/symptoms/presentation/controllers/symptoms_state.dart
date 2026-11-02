import 'package:equatable/equatable.dart';

import '../../domain/entities/symptom_entity.dart';

/// The reported symptoms; null until the phone's copy has loaded.
class SymptomsState extends Equatable {
  const SymptomsState({this.symptoms, this.refreshing = false});

  final List<SymptomEntity>? symptoms;

  /// True while the server's list is being fetched.
  final bool refreshing;

  bool get isLoading => symptoms == null || (symptoms!.isEmpty && refreshing);

  SymptomsState copyWith({List<SymptomEntity>? symptoms, bool? refreshing}) =>
      SymptomsState(
          symptoms: symptoms ?? this.symptoms,
          refreshing: refreshing ?? this.refreshing);

  @override
  List<Object?> get props => [symptoms, refreshing];
}
