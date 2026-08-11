import 'package:equatable/equatable.dart';
import '../../domain/entities/symptom_entity.dart';

class SymptomsState extends Equatable {
  final bool isLoading;
  final bool isInitialized;
  final List<SymptomEntity> symptoms;
  final String? error;

  const SymptomsState({
    this.isLoading = false,
    this.isInitialized = false,
    this.symptoms = const [],
    this.error,
  });

  SymptomsState copyWith({
    bool? isLoading,
    bool? isInitialized,
    List<SymptomEntity>? symptoms,
    String? error,
  }) {
    return SymptomsState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      symptoms: symptoms ?? this.symptoms,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, isInitialized, symptoms, error];
}
