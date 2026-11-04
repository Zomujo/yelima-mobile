import 'dart:async';

import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../domain/models/medication_detail_model.dart';
import '../states/medication_form_state.dart';
import 'medication_form_controller.dart';

part 'medicine_details_form_controller.g.dart';

/// One medication's details screen: its data, dose history and edit form.
@riverpod
class MedicineDetailsFormController extends _$MedicineDetailsFormController
    with MedicationFormController {
  /// The id in use; a medication added offline gets its server id once it syncs.
  late String _id;
  DateTime? _month;

  @override
  MedicineDetailsState build(String medicationId) {
    _id = medicationId;
    startForm(ref);
    final sub = repository.onIdChanged.listen((ids) {
      if (ids.$1 != _id) return;
      _id = ids.$2;
      init();
    });
    ref.onDispose(sub.cancel);
    Future.microtask(init);
    return MedicineDetailsState(form: MedicationFormState.blank());
  }

  @override
  MedicationFormState get fields => state.form;

  @override
  set fields(MedicationFormState value) => state = state.copyWith(form: value);

  @override
  String get name => state.name;

  /// Shows the phone's copy at once, then the server's details and this month's history.
  Future<void> init() async {
    if (disposed) return;
    loadHistory(clock.now());
    final cached = await repository.getCachedMedication(_id);
    if (disposed) return;
    if (cached != null) _show(cached);
    final result = await repository.getMedicationById(_id);
    if (disposed) return;
    // A failed refresh keeps the phone's copy on screen.
    result.fold(
        (f) => state = state.copyWith(
            isLoading: false, error: state.detail == null ? f : null),
        _show);
  }

  void _show(MedicationDetailModel data) {
    state = state.copyWith(detail: data, error: null, isLoading: false);
    if (!state.isEditing) load(data);
  }

  /// Shows [month]'s doses from the phone, then from the server.
  Future<void> loadHistory(DateTime month) async {
    _month = month;
    final cached = await repository.getCachedHistory(_id, month);
    if (disposed || _month != month) return;
    state = state.copyWith(history: cached);
    final result = await repository.getMedicationHistory(_id, month);
    // A slower reply for a month no longer shown is dropped.
    if (disposed || _month != month) return;
    state = result.fold((f) => state.copyWith(historyError: f),
        (h) => state.copyWith(history: h, historyError: null));
  }

  /// Starts or stops editing; stopping drops unsaved changes.
  void setEditing(bool value) {
    state = state.copyWith(isEditing: value);
    if (!value && state.detail != null) load(state.detail!);
  }

  @override
  Future<AppFailure?> persist() async {
    final result = await repository.updateMedication(_id, form);
    if (result.isLeft()) return result.fold((f) => f, (_) => null);
    if (disposed) return null;
    state = state.copyWith(isEditing: false);
    await init();
    return null;
  }

  /// Deletes this medication and its reminders.
  AsyncResult<void> delete() => repository.deleteMedication(_id);
}
