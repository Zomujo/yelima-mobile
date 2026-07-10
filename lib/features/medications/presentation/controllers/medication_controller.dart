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

  void init() {
    fetchAdherence();
    fetchCounts();
    fetchMedications();
  }

  void setTabIndex(int index) {
    if (state.selectedTabIndex != index) {
      state = state.copyWith(selectedTabIndex: index);
      fetchMedications();
    }
  }

  Future<void> fetchAdherence() async {
    if (state.adherence == null) {
      state = state.copyWith(isAdherenceLoading: true, adherenceError: null);

      final cachedResult = await repository.getCachedAdherence(showWeekdays: true);
      cachedResult.fold((_) => null, (data) {
        if (data.days.isNotEmpty) {
          state = state.copyWith(adherence: data, isAdherenceLoading: false, adherenceError: null);
        }
      });
    }

    if (state.adherence == null) {
      state = state.copyWith(isAdherenceLoading: true, adherenceError: null);
    }

    final result = await repository.getAdherence(showWeekdays: true);
    result.fold(
      (error) {
        state = state.copyWith(adherenceError: error, isAdherenceLoading: false);
      },
      (data) {
        state = state.copyWith(adherence: data, isAdherenceLoading: false, adherenceError: null);
      },
    );
  }

  Future<void> fetchCounts() async {
    if (state.counts == null) {
      state = state.copyWith(isCountsLoading: true, countsError: null);

      final cachedResult = await repository.getCachedMedicationCounts();
      cachedResult.fold((_) => null, (data) {
        state = state.copyWith(counts: data, isCountsLoading: false, countsError: null);
      });
    }

    if (state.counts == null) {
      state = state.copyWith(isCountsLoading: true, countsError: null);
    }

    final result = await repository.getMedicationCounts();
    result.fold(
      (error) {
        state = state.copyWith(countsError: error, isCountsLoading: false);
      },
      (data) {
        state = state.copyWith(counts: data, isCountsLoading: false, countsError: null);
      },
    );
  }

  Future<void> fetchMedications() async {
    final section = _currentSection;
    final currentList = state.medicationsBySection[section];

    if (currentList == null) {
      _setSectionLoading(section, true);
      _setSectionError(section, null);

      final cachedResult = await repository.getCachedMedicationsBySection(section);
      cachedResult.fold((_) => null, (data) {
        if (data.isNotEmpty) {
          _setSectionData(section, data);
          _setSectionLoading(section, false);
        }
      });
    }

    if (state.medicationsBySection[section] == null) {
      _setSectionLoading(section, true);
    }

    final result = await repository.getMedicationsBySection(section);
    result.fold(
      (error) {
        _setSectionError(section, error);
        _setSectionLoading(section, false);
      },
      (data) {
        _setSectionData(section, data);
        _setSectionLoading(section, false);
      },
    );
  }

  void _setSectionLoading(String section, bool isLoading) {
    state = state.copyWith(
      sectionLoadingStatus: {
        ...state.sectionLoadingStatus,
        section: isLoading,
      },
    );
  }

  void _setSectionError(String section, String? error) {
    final newErrors = Map<String, String>.from(state.sectionErrors);
    if (error == null) {
      newErrors.remove(section);
    } else {
      newErrors[section] = error;
    }
    state = state.copyWith(sectionErrors: newErrors);
  }

  void _setSectionData(String section, List<MedicationEntity> data) {
    state = state.copyWith(
      medicationsBySection: {
        ...state.medicationsBySection,
        section: data,
      },
    );
  }

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

    state = state.copyWith(confirmingMedicationId: id);

    final updatedMed = med.copyWith(taken: true);
    final newList = List<MedicationEntity>.from(currentList);
    newList[index] = updatedMed;

    _setSectionData(section, newList);

    final result = await repository.confirmMedication(id, section);
    return result.fold(
      (error) {
        state = state.copyWith(confirmingMedicationId: null);
        
        // Revert on failure
        final revertedList = List<MedicationEntity>.from(state.medicationsBySection[section] ?? []);
        final revertIndex = revertedList.indexWhere((m) => m.id == id);
        if (revertIndex != -1) {
          revertedList[revertIndex] = med;
          _setSectionData(section, revertedList);
        }
        return error;
      },
      (_) {
        state = state.copyWith(confirmingMedicationId: null);
        fetchAdherence();
        return null;
      },
    );
  }
}
