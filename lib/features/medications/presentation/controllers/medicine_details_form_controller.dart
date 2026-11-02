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
  AppFailure? historyError;
  DateTime? _month;

  @override
  String get name => detail?.name ?? '';

  /// Shows the phone's copy at once, then the server's details and this month's history.
  Future<void> init() async {
    loadHistory(clock.now());
    if (await _repository.getCachedMedication(medicationId)
        case final cached?) {
      _show(cached);
    }
    final result = await _repository.getMedicationById(medicationId);
    isLoading = false;
    // A failed refresh keeps the phone's copy on screen.
    result.fold((f) => error = detail == null ? f : null, _show);
    notifyListeners();
  }

  void _show(MedicationDetailModel data) {
    detail = data;
    error = null;
    isLoading = false;
    if (!isEditing) load(data);
    notifyListeners();
  }

  /// Shows [month]'s doses from the phone, then from the server.
  Future<void> loadHistory(DateTime month) async {
    _month = month;
    final cached = await _repository.getCachedHistory(medicationId, month);
    if (_month != month) return;
    history = cached;
    notifyListeners();
    final result = await _repository.getMedicationHistory(medicationId, month);
    // A slower reply for a month no longer shown is dropped.
    if (_month != month) return;
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

  /// Deletes this medication and its reminders.
  AsyncResult<void> delete() => _repository.deleteMedication(medicationId);

  @override
  void dispose() {
    _idSub.cancel();
    super.dispose();
  }
}
