import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../symptoms_providers.dart';
import 'symptoms_state.dart';

part 'symptoms_controller.g.dart';

/// The reported symptoms, kept live from the phone and refreshed from the server.
@Riverpod(keepAlive: true)
class SymptomsController extends _$SymptomsController {
  @override
  SymptomsState build() {
    final sub = ref
        .watch(symptomsRepositoryProvider)
        .watchSymptoms()
        .listen((list) => state = state.copyWith(symptoms: list));
    ref.onDispose(sub.cancel);
    Future.microtask(fetchSymptoms);
    return const SymptomsState();
  }

  /// Refreshes from the server (at most every 5 minutes unless [force]).
  Future<void> fetchSymptoms({bool force = false}) async {
    state = state.copyWith(refreshing: true);
    await ref.read(symptomsRepositoryProvider).refresh(force: force);
    state = state.copyWith(refreshing: false);
  }

  /// Reports a new symptom.
  AsyncResult<String> createSymptom(String description) =>
      ref.read(symptomsRepositoryProvider).createSymptom(description);
}
