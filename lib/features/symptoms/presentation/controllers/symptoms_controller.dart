import 'package:flutter/material.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../domain/entities/symptom_entity.dart';
import '../../domain/repositories/symptoms_repository.dart';
import '../../../../core/utils/custom_types.dart';
import 'symptoms_state.dart';

class SymptomsController extends ChangeNotifier with SafeNotifier {
  // --------------------------------------------------------------------------
  // |                                  State & Dependencies                  |
  // --------------------------------------------------------------------------

  final SymptomsRepository _repository;

  SymptomsState _state = const SymptomsState();
  SymptomsState get state => _state;

  // --------------------------------------------------------------------------
  // |                               Initialization & Lifecycle                |
  // --------------------------------------------------------------------------

  SymptomsController({
    required SymptomsRepository repository,
  }) : _repository = repository;

  set state(SymptomsState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // |                                   Actions & Methods                    |
  // --------------------------------------------------------------------------

  Future<void> fetchSymptoms({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, error: null);
    }

    final result = await _repository.getSymptoms(page: 1, pageSize: 100);

    result.fold(
      (error) {
        state =
            state.copyWith(isLoading: false, error: error, isInitialized: true);
      },
      (symptoms) {
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          symptoms: symptoms,
          error: null,
        );
      },
    );
  }

  /// Reports a new symptom and refreshes the list on success.
  AsyncResponse<String> createSymptom(String description) async {
    final result = await _repository.createSymptom(description);
    if (result.isRight()) fetchSymptoms(silent: true);
    return result;
  }

  // --------------------------------------------------------------------------
  // |                                   Computed UI State                    |
  // --------------------------------------------------------------------------

  /// Returns symptoms grouped by date strings like "Today", "Yesterday", "10th July 2026"
  Map<String, List<SymptomEntity>> get groupedSymptoms {
    final Map<String, List<SymptomEntity>> groups = {};

    // Sort symptoms descending by date
    final sortedSymptoms = List<SymptomEntity>.from(state.symptoms)
      ..sort((a, b) => b.onsetDate.compareTo(a.onsetDate));

    for (var symptom in sortedSymptoms) {
      final dateStr = DateTimeUtils.formatDate(symptom.onsetDate);
      if (!groups.containsKey(dateStr)) {
        groups[dateStr] = [];
      }
      groups[dateStr]!.add(symptom);
    }

    return groups;
  }
}
