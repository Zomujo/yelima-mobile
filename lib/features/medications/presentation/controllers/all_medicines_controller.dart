import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_history_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../data/models/create_medication_model.dart';
import '../../data/models/update_medication_model.dart';
import '../../data/models/medication_detail_model.dart';
import '../../data/models/seeded_medication_list_response_model.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../states/medication_state.dart';

class AllMedicinesController extends ChangeNotifier with SafeNotifier {
  final MedicationRepository repository;

  AllMedicinesController({required this.repository});

  MedicationState<MedicationListResponse> listState = const MedicationState();

  // Cache for histories keyed by medication ID
  final Map<String, MedicationState<MedicationHistoryEntity>> historyStates =
      {};

  // New states for the UI
  MedicationState<SeededMedicationListResponseModel> preloadedState =
      const MedicationState();
  MedicationState<MedicationDetailModel> detailState = const MedicationState();
  MedicationState<String> formSubmitState = const MedicationState();

  // Add subscription
  StreamSubscription<List<MedicationEntity>>? _medicationSubscription;

  void fetchAllMedicines({bool forceRefresh = false}) async {
    if (listState.data == null) {
      listState = listState.copyWith(isLoading: true, error: null);
      notifyListeners();

      final cachedResult = await repository.getCachedAllMedications();
      cachedResult.fold((_) => null, (data) {
        if (data.rows.isNotEmpty) {
          listState =
              listState.copyWith(data: data, isLoading: false, error: null);
          notifyListeners();
        }
      });
    }

    if (listState.data == null) {
      listState = listState.copyWith(isLoading: true, error: null);
      notifyListeners();
    }

    // Trigger background fetch to update the remote data
    final refreshResult = await repository.getAllMedications(
        page: 1, pageSize: 50, forceRefresh: forceRefresh);
    refreshResult.fold((failure) {
      // Only surface the error if we still have nothing to show - if we
      // already have cached/local data, silently rely on that instead.
      if (listState.data == null || listState.data!.rows.isEmpty) {
        listState =
            listState.copyWith(error: failure, isLoading: false);
        notifyListeners();
      }
    }, (_) => null);

    // Watch local database for updates
    _medicationSubscription?.cancel();
    _medicationSubscription =
        repository.watchAllMedications().listen((entities) {
      final response = MedicationListResponse(
        rows: entities,
        total: entities.length,
        pageSize: 50,
        page: 1,
        totalPages: (entities.length / 50).ceil() == 0
            ? 1
            : (entities.length / 50).ceil(),
      );

      listState =
          listState.copyWith(data: response, isLoading: false, error: null);
      notifyListeners();
    }, onError: (error) {
      listState = listState.copyWith(error: error.toString(), isLoading: false);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _medicationSubscription?.cancel();
    super.dispose();
  }

  void fetchMedicationHistory(String id, {DateTime? targetMonth}) async {
    final month = targetMonth ?? DateTime.now();
    // Format as yyyy-MM-15
    final date = DateFormat('yyyy-MM-15').format(month);

    historyStates[id] = const MedicationState(isLoading: true);
    notifyListeners();

    final result = await repository.getMedicationHistory(id, date: date);
    result.fold(
      (failure) {
        historyStates[id] =
            MedicationState(error: failure, isLoading: false);
        notifyListeners();
      },
      (data) {
        historyStates[id] =
            MedicationState(data: data, isLoading: false, error: null);
        notifyListeners();
      },
    );
  }

  Future<void> fetchPreloadedMedications(
      {String? search, int page = 1, int limit = 10}) async {
    preloadedState = preloadedState.copyWith(isLoading: true, error: null);
    notifyListeners();

    final result = await repository.getPreloadedMedications(
        page: page, limit: limit, search: search);
    result.fold(
      (failure) {
        preloadedState =
            preloadedState.copyWith(error: failure, isLoading: false);
        notifyListeners();
      },
      (data) {
        preloadedState =
            preloadedState.copyWith(data: data, isLoading: false, error: null);
        notifyListeners();
      },
    );
  }

  Future<void> fetchMedicationDetails(String id) async {
    detailState = const MedicationState(isLoading: true);
    notifyListeners();

    final result = await repository.getMedicationById(id);
    result.fold(
      (failure) {
        detailState = MedicationState(error: failure, isLoading: false);
        notifyListeners();
      },
      (data) {
        detailState =
            MedicationState(data: data, isLoading: false, error: null);
        notifyListeners();
      },
    );
  }

  Future<bool> createMedication(CreateMedicationModel data) async {
    formSubmitState = const MedicationState(isLoading: true);
    notifyListeners();

    final result = await repository.createMedication(data);
    return result.fold(
      (failure) {
        formSubmitState =
            MedicationState(error: failure, isLoading: false);
        notifyListeners();
        return false;
      },
      (successMsg) {
        formSubmitState =
            MedicationState(data: successMsg, isLoading: false, error: null);
        notifyListeners();
        fetchAllMedicines(forceRefresh: true); // Refresh list after creation
        return true;
      },
    );
  }

  Future<bool> updateMedication(String id, UpdateMedicationModel data) async {
    formSubmitState = const MedicationState(isLoading: true);
    notifyListeners();

    final result = await repository.updateMedication(id, data);
    return result.fold(
      (failure) {
        formSubmitState =
            MedicationState(error: failure, isLoading: false);
        notifyListeners();
        return false;
      },
      (successMsg) {
        formSubmitState =
            MedicationState(data: successMsg, isLoading: false, error: null);
        notifyListeners();
        fetchAllMedicines(forceRefresh: true); // Refresh list after update
        fetchMedicationDetails(id); // Refresh details
        return true;
      },
    );
  }
}
