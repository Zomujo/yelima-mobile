import 'package:equatable/equatable.dart';

class MedicationCount extends Equatable {
  final int morning;
  final int afternoon;
  final int evening;

  const MedicationCount({
    required this.morning,
    required this.afternoon,
    required this.evening,
  });

  @override
  List<Object?> get props => [morning, afternoon, evening];
}
