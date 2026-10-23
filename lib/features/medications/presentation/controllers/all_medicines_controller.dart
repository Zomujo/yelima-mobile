import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../../../core/utils/session_scoped.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/repositories/medication_repository.dart';

/// The all-medicines list, kept live from the phone's database.
class AllMedicinesController extends ChangeNotifier
    with SafeNotifier, SessionScoped {
  AllMedicinesController({required MedicationRepository repository})
      : _repository = repository {
    joinSession();
  }

  final MedicationRepository _repository;
  StreamSubscription<List<MedicationEntity>>? _sub;

  /// Null until the list has loaded.
  List<MedicationEntity>? medicines;

  @override
  String get serviceName => 'AllMedicinesController';

  @override
  Future<void> onSessionStarted(String userId) async {}

  @override
  Future<void> onSessionEnded() async {
    await _sub?.cancel();
    _sub = null;
    medicines = null;
    notifyListeners();
  }

  /// Follows the list and refreshes it from the server.
  void init() {
    _sub ??= _repository.watchAll().listen((list) {
      medicines = list;
      notifyListeners();
    });
    _repository.refreshAll();
  }

  /// Deletes a medication; the list updates itself.
  AsyncResult<void> delete(String id) => _repository.deleteMedication(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
