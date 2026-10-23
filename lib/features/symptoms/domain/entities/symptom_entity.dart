import 'package:equatable/equatable.dart';

/// A symptom the patient reported, and when.
class SymptomEntity extends Equatable {
  const SymptomEntity({
    required this.id,
    required this.description,
    required this.onsetDate,
  });

  final String id;
  final String description;
  final DateTime onsetDate;

  @override
  List<Object?> get props => [id, description, onsetDate];
}
