import 'package:equatable/equatable.dart';

class SymptomEntity extends Equatable {
  final String id;
  final String description;
  final DateTime onsetDate;

  const SymptomEntity({
    required this.id,
    required this.description,
    required this.onsetDate,
  });

  @override
  List<Object?> get props => [id, description, onsetDate];
}
