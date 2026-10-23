import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../../core/services/session_lifecycle_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/db/app_database.dart';
import '../datasources/medication_remote_datasource.dart';
import 'package:yelima/features/medications/domain/models/seeded_medication_model.dart';

/// Downloads the preloaded medication list for the add form when a session starts.
class SeededMedicationsSyncService implements SessionLifecycleHandler {
  SeededMedicationsSyncService(
      this._remoteDataSource, this._db, this._connectivityService);

  final MedicationRemoteDataSource _remoteDataSource;
  final AppDatabase _db;
  final ConnectivityService _connectivityService;

  @override
  String get serviceName => 'SeededMedicationsSyncService';

  /// Runs in the background so it never delays sign-in.
  @override
  Future<void> onSessionStarted(String userId) async {
    _sync().catchError(
        (Object e) => debugPrint('Preloaded medications sync failed: $e'));
  }

  @override
  Future<void> onSessionEnded() async {}

  /// Replaces the cached list page by page, stopping if the connection drops.
  Future<void> _sync() async {
    if (!await _connectivityService.isConnected) return;
    final first =
        await _remoteDataSource.getPreloadedMedications(page: 1, limit: 100);
    await _db.medicationsDao.clearPreloadedMedications();
    await _save(first.rows);
    for (var page = 2; page <= first.totalPages; page++) {
      if (!await _connectivityService.isConnected) break;
      await _save((await _remoteDataSource.getPreloadedMedications(
              page: page, limit: 100))
          .rows);
    }
  }

  Future<void> _save(List<SeededMedicationModel> rows) =>
      _db.medicationsDao.insertPreloadedMedications([
        for (final e in rows)
          PreloadedMedication(
              id: e.id,
              name: e.name,
              possibleDosagesJson: jsonEncode(e.possibleDosages)),
      ]);
}
