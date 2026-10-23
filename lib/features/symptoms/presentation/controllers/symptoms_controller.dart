import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../domain/entities/symptom_entity.dart';
import '../../domain/repositories/symptoms_repository.dart';
import 'symptoms_state.dart';

/// The reported symptoms, kept live from the phone and refreshed from the server.
class SymptomsController extends ChangeNotifier with SafeNotifier {
  SymptomsController({required SymptomsRepository repository})
      : _repository = repository {
    _sub = _repository
        .watchSymptoms()
        .listen((list) => state = SymptomsState(symptoms: list));
  }

  final SymptomsRepository _repository;
  late final StreamSubscription<List<SymptomEntity>> _sub;

  SymptomsState _state = const SymptomsState();
  SymptomsState get state => _state;
  set state(SymptomsState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  /// Refreshes from the server (at most every 5 minutes unless [force]).
  Future<void> fetchSymptoms({bool force = false}) =>
      _repository.refresh(force: force);

  /// Reports a new symptom.
  AsyncResult<String> createSymptom(String description) =>
      _repository.createSymptom(description);

  /// Symptoms grouped by the day they started, newest day first.
  List<(DateTime day, List<SymptomEntity> symptoms)> get byDay {
    final sorted = [...?state.symptoms]
      ..sort((a, b) => b.onsetDate.compareTo(a.onsetDate));
    final groups = <DateTime, List<SymptomEntity>>{};
    for (final s in sorted) {
      final d = s.onsetDate;
      groups.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(s);
    }
    return [for (final e in groups.entries) (e.key, e.value)];
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
