import 'package:equatable/equatable.dart';

import '../../domain/entities/symptom_entity.dart';

/// The reported symptoms; null until the phone's copy has loaded.
class SymptomsState extends Equatable {
  const SymptomsState({this.symptoms});

  final List<SymptomEntity>? symptoms;

  @override
  List<Object?> get props => [symptoms];
}
