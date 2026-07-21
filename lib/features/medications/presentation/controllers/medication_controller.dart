import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_adherence.dart';
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

  StreamSubscription<MedicationCount>? _countsSubscription;
  StreamSubscription<List<MedicationEntity>>? _medsSubscription;
  StreamSubscription<MedicationAdherence>? _adherenceSubscription;

  void init() {
    fetchAdherence();

    _adherenceSubscription?.cancel();
    _adherenceSubscription = repository.watchAdherence().listen((data) {
      if (data.days.isNotEmpty || data.rate > 0) {
        state = state.copyWith(
            adherence: data, isAdherenceLoading: false, adherenceError: null);
      } else {
        // If empty, keep what we have or just set empty. We'll set it.
        state = state.copyWith(
            adherence: data, isAdherenceLoading: false, adherenceError: null);
      }
    }, onError: (e) {
      state = state.copyWith(
          adherenceError: e.toString(), isAdherenceLoading: false);
    });

    _countsSubscription?.cancel();
    _countsSubscription = repository.watchMedicationCounts().listen((counts) {
      state = state.copyWith(
          counts: counts, isCountsLoading: false, countsError: null);
    }, onError: (e) {
      state = state.copyWith(countsError: e.toString(), isCountsLoading: false);
    });

    _subscribeToCurrentSection();
  }

  void _subscribeToCurrentSection() {
    final section = _currentSection;
    _setSectionLoading(section, true);

    _medsSubscription?.cancel();
    _medsSubscription =
        repository.watchMedicationsBySection(section).listen((meds) async {
      _setSectionData(section, meds);

      _setSectionLoading(section, false);
      _setSectionError(section, null);
    }, onError: (e) {
      _setSectionError(section, e.toString());
      _setSectionLoading(section, false);
    });

    _refreshSection(section);
  }

  Future<void> _refreshSection(String section) async {
    final result = await repository.getMedicationsBySection(section);
    result.fold((error) {
      final hasData = state.medicationsBySection[section]?.isNotEmpty ?? false;
      if (!hasData) _setSectionError(section, error);
      _setSectionLoading(section, false);
    }, (_) {
      _setSectionLoading(section, false);
    });
  }

  @override
  void dispose() {
    _countsSubscription?.cancel();
    _medsSubscription?.cancel();
    _adherenceSubscription?.cancel();
    super.dispose();
  }

  void setTabIndex(int index) {
    if (state.selectedTabIndex != index) {
      state = state.copyWith(selectedTabIndex: index);
      _subscribeToCurrentSection();
    }
  }

  Future<void> fetchAdherence() async {
    // Triggers network fetch which natively updates the DB stream
    await repository.getAdherence(showWeekdays: true);
  }

  // Legacy stubs kept for compatibility if called elsewhere temporarily
  Future<void> fetchCounts() async {}
  Future<void> fetchMedications() async {}

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

    if (state.confirmingMedicationIds.contains(id)) return null;

    state = state.copyWith(
      confirmingMedicationIds: {...state.confirmingMedicationIds, id},
    );

    final updatedMed = med.copyWith(taken: true);
    final newList = List<MedicationEntity>.from(currentList);
    newList[index] = updatedMed;

    _setSectionData(section, newList);

    final result = await repository.confirmMedication(id, section);
    return result.fold(
      (error) {
        final newConfirming = Set<String>.from(state.confirmingMedicationIds);
        newConfirming.remove(id);
        state = state.copyWith(confirmingMedicationIds: newConfirming);

        // Revert on failure
        final revertedList = List<MedicationEntity>.from(
            state.medicationsBySection[section] ?? []);
        final revertIndex = revertedList.indexWhere((m) => m.id == id);
        if (revertIndex != -1) {
          revertedList[revertIndex] = med;
          _setSectionData(section, revertedList);
        }
        return error;
      },
      (_) {
        final newConfirming = Set<String>.from(state.confirmingMedicationIds);
        newConfirming.remove(id);
        state = state.copyWith(confirmingMedicationIds: newConfirming);
        fetchAdherence();
        return null;
      },
    );
  }
}
