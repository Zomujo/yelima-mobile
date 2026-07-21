import 'package:flutter/material.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../states/medications_state.dart';

class MedicationController extends ChangeNotifier with SafeNotifier {
  final MedicationRepository repository;

  MedicationController({required this.repository});

  MedicationsState _state = const MedicationsState();
  MedicationsState get state => _state;

  set state(MedicationsState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  String get _currentSection {
    switch (state.selectedTabIndex) {
      case 0:
        return 'MORNING';
      case 1:
        return 'AFTERNOON';
      case 2:
        return 'EVENING';
      default:
        return 'MORNING';
    }
  }

  /// Initializes the controller by fetching adherence, counts, and medications.
  void init() {
    fetchAdherence();
    fetchCounts();
    fetchMedications();
  }

  /// Updates the selected tab index and refreshes the medication list for that time of day.
  void setTabIndex(int index) {
    if (state.selectedTabIndex != index) {
      state = state.copyWith(selectedTabIndex: index);
      fetchMedications();
    }
  }

  /// Fetches the user's overall medication adherence rate from the backend.
  Future<void> fetchAdherence() async {
    state = state.copyWith(isAdherenceLoading: true, adherenceError: null);
    final result = await repository.getAdherence(showWeekdays: true);

    state = result.fold(
      (error) =>
          state.copyWith(isAdherenceLoading: false, adherenceError: error),
      (data) => state.copyWith(
          isAdherenceLoading: false, adherence: data, adherenceError: null),
    );
  }

  /// Fetches the number of medications taken and missed for the day.
  Future<void> fetchCounts() async {
    state = state.copyWith(isCountsLoading: true, countsError: null);
    final result = await repository.getMedicationCounts();

    state = result.fold(
      (error) => state.copyWith(isCountsLoading: false, countsError: error),
      (data) => state.copyWith(
          isCountsLoading: false, counts: data, countsError: null),
    );
  }

  /// Fetches the medication list for the currently selected time section.
  Future<void> fetchMedications() async {
    final section = _currentSection;
    _setSectionLoading(section, true);

    final result = await repository.getMedicationsBySection(section);

    state = result.fold(
      (error) => _buildStateWithError(section, error, false),
      (data) => _buildStateWithData(section, data, false),
    );
  }

  MedicationsState _buildStateWithError(
      String section, String error, bool isLoading) {
    final newErrors = Map<String, String>.from(state.sectionErrors)
      ..[section] = error;
    final newLoading = Map<String, bool>.from(state.sectionLoadingStatus)
      ..[section] = isLoading;
    return state.copyWith(
        sectionErrors: newErrors, sectionLoadingStatus: newLoading);
  }

  MedicationsState _buildStateWithData(
      String section, List<MedicationEntity> data, bool isLoading) {
    final newErrors = Map<String, String>.from(state.sectionErrors)
      ..remove(section);
    final newLoading = Map<String, bool>.from(state.sectionLoadingStatus)
      ..[section] = isLoading;
    final newMeds =
        Map<String, List<MedicationEntity>>.from(state.medicationsBySection)
          ..[section] = data;
    return state.copyWith(
      sectionErrors: newErrors,
      sectionLoadingStatus: newLoading,
      medicationsBySection: newMeds,
    );
  }

  void _setSectionLoading(String section, bool isLoading) {
    final newLoading = Map<String, bool>.from(state.sectionLoadingStatus)
      ..[section] = isLoading;
    state = state.copyWith(sectionLoadingStatus: newLoading);
  }

  /// Optimistically marks a medication as taken and syncs the update with the backend.
  Future<String?> toggleMedicationStatus(String id) async {
    final section = _currentSection;
    final currentList = state.medicationsBySection[section];
    if (currentList == null) return null;

    final index = currentList.indexWhere((m) => m.id == id);
    if (index == -1) return null;

    final med = currentList[index];
    if (med.taken) return null;

    if (DateTime.now().isBefore(med.toBeTakenAt)) {
      return 'Cannot confirm dose — it\'s not yet time.';
    }

    if (state.confirmingMedicationIds.contains(id)) return null;

    _setConfirming(id, true);

    final newList = List<MedicationEntity>.from(currentList);
    newList[index] = med.copyWith(taken: true);
    state = _buildStateWithData(
        section, newList, state.sectionLoadingStatus[section] ?? false);

    final result = await repository.confirmMedication(id, section);

    return result.fold(
      (error) {
        _setConfirming(id, false);

        final revertedList = List<MedicationEntity>.from(
            state.medicationsBySection[section] ?? []);
        final revertIndex = revertedList.indexWhere((m) => m.id == id);
        if (revertIndex != -1) {
          revertedList[revertIndex] = med;
          state = _buildStateWithData(section, revertedList,
              state.sectionLoadingStatus[section] ?? false);
        }
        return error;
      },
      (_) {
        _setConfirming(id, false);
        fetchAdherence();
        return null;
      },
    );
  }

  void _setConfirming(String id, bool isConfirming) {
    final newConfirming = Set<String>.from(state.confirmingMedicationIds);
    if (isConfirming) {
      newConfirming.add(id);
    } else {
      newConfirming.remove(id);
    }
    state = state.copyWith(confirmingMedicationIds: newConfirming);
  }
}
