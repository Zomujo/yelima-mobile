class MedicationState<T> {
  final T? data;
  final bool isLoading;
  final String? error;

  const MedicationState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  MedicationState<T> copyWith({
    T? data,
    bool? isLoading,
    String? error,
  }) {
    return MedicationState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      // If error is null in copyWith, we check if we want to explicitly clear it
      // but usually we just set it directly to what's passed
      error: error,
    );
  }
}
