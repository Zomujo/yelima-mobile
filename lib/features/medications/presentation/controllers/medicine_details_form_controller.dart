import 'dart:async';

import 'package:clock/clock.dart';

import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/medication_history_entity.dart';
import '../../domain/models/medication_detail_model.dart';
import '../../domain/repositories/medication_repository.dart';
import 'medication_form_controller.dart';

/// One medication's details screen: its data, dose history and edit form.
class MedicineDetailsFormController extends MedicationFormController {
  MedicineDetailsFormController(
      {required MedicationRepository repository, required this.medicationId})
      : _repository = repository {
    // A medication added offline gets its server id once it syncs.
    _idSub = _repository.onIdChanged.listen((ids) {
      if (ids.$1 != medicationId) return;
      medicationId = ids.$2;
      init();
    });
  }

  final MedicationRepository _repository;
  late final StreamSubscription<(String, String)> _idSub;
  String medicationId;

  MedicationDetailModel? detail;
  AppFailure? error;
  bool isLoading = true;
  bool isEditing = false;
  MedicationHistoryEntity? history;
  bool isHistoryLoading = true;
  AppFailure? historyError;

  @override
  String get name => detail?.name ?? '';

  /// Loads the details and this month's history.
  Future<void> init() async {
    loadHistory(clock.now());
    final result = await _repository.getMedicationById(medicationId);
    isLoading = false;
    result.fold((f) => error = f, (data) {
      detail = data;
      error = null;
      load(data);
    });
    notifyListeners();
  }

  /// Loads the dose history for [month].
  Future<void> loadHistory(DateTime month) async {
    isHistoryLoading = true;
    notifyListeners();
    final result = await _repository.getMedicationHistory(medicationId, month);
    isHistoryLoading = false;
    result.fold((f) => historyError = f, (h) {
      history = h;
      historyError = null;
    });
    notifyListeners();
  }

  /// Starts or stops editing; stopping drops unsaved changes.
  void setEditing(bool value) {
    isEditing = value;
    if (!value && detail != null) load(detail!);
    notifyListeners();
  }

  @override
  Future<AppFailure?> persist() async {
    final result = await _repository.updateMedication(medicationId, form);
    if (result.isLeft()) return result.fold((f) => f, (_) => null);
    isEditing = false;
    await init();
    return null;
  }

  @override
  void dispose() {
    _idSub.cancel();
    super.dispose();
  }
}
