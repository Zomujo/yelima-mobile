import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/utils/follow_session.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../medications_providers.dart';

part 'all_medicines_controller.g.dart';

/// The all-medicines list, kept live from the phone's database; null until loaded.
@Riverpod(keepAlive: true)
class AllMedicinesController extends _$AllMedicinesController {
  late MedicationRepository _repository;
  StreamSubscription<List<MedicationEntity>>? _sub;

  @override
  List<MedicationEntity>? build() {
    _repository = ref.watch(medicationRepositoryProvider);
    followSession(ref, onEnd: () async {
      await _stop();
      state = null;
    });
    ref.onDispose(_stop);
    return null;
  }

  Future<void> _stop() async {
    final sub = _sub;
    _sub = null;
    await sub?.cancel();
  }

  /// Follows the list and refreshes it from the server.
  void init() {
    _sub ??= _repository.watchAll().listen((list) => state = list);
    _repository.refreshAll();
  }

  /// Deletes a medication; the list updates itself.
  AsyncResult<void> delete(String id) => _repository.deleteMedication(id);
}
