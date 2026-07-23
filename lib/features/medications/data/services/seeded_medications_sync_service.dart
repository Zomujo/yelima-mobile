import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../../core/services/session_lifecycle_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/db/app_database.dart';
import '../datasources/medication_remote_datasource.dart';
import '../models/seeded_medication_model.dart';

class SeededMedicationsSyncService implements SessionLifecycleHandler {
  final MedicationRemoteDataSource _remoteDataSource;
  final AppDatabase _db;
  final ConnectivityService _connectivityService;

  SeededMedicationsSyncService(
      this._remoteDataSource, this._db, this._connectivityService);

  @override
  String get serviceName => 'SeededMedicationsSyncService';

  @override
  Future<void> onSessionStarted(String userId) async {
    // Start background sync without blocking session initialization
    _performSync().catchError((e) {
      debugPrint('Background sync for seeded medications failed: $e');
    });
  }

  @override
  Future<void> onSessionEnded() async {
    // No cleanup required for preloaded cache
  }

  Future<void> _performSync() async {
    if (!await _connectivityService.isConnected) return;

    try {
      debugPrint('SeededMedicationsSyncService: Starting background sync...');
      
      // Fetch first page to get total pages
      final firstPageRes = await _remoteDataSource.getPreloadedMedications(
          page: 1, limit: 100);

      // Wipe old cache completely as per our cache strategy
      await _db.medicationsDao.clearPreloadedMedications();

      // Insert first page
      await _insertPage(firstPageRes.rows);

      final totalPages = firstPageRes.totalPages;

      // Recursively fetch remaining pages
      for (int i = 2; i <= totalPages; i++) {
        if (!await _connectivityService.isConnected) break; // abort if offline

        final pageRes = await _remoteDataSource.getPreloadedMedications(
            page: i, limit: 100);
        await _insertPage(pageRes.rows);
      }

      debugPrint('SeededMedicationsSyncService: Background sync complete.');
    } catch (e) {
      debugPrint('SeededMedicationsSyncService: Sync error: $e');
    }
  }

  Future<void> _insertPage(List<SeededMedicationModel> rows) async {
    final meds = rows
        .map((e) => PreloadedMedication(
              id: e.id,
              name: e.name,
              possibleDosagesJson: jsonEncode(e.possibleDosages),
            ))
        .toList();
    await _db.medicationsDao.insertPreloadedMedications(meds);
  }
}
