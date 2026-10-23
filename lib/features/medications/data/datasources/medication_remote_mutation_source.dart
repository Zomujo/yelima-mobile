import 'dart:convert';
import '../../../../core/api/i_remote_mutation.dart';
import 'medication_remote_datasource.dart';
import 'package:yelima/features/medications/domain/models/create_medication_model.dart';
import 'package:yelima/features/medications/domain/models/update_medication_model.dart';
import '../../../../core/db/app_database.dart';

/// Replays queued medication changes to the server.
class MedicationRemoteMutationSource implements IRemoteMutationSource {
  final MedicationRemoteDataSource _remoteDataSource;
  final AppDatabase _db;

  MedicationRemoteMutationSource(this._remoteDataSource, this._db);

  @override
  Future<String?> syncMutation({
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) async {
    final payload = jsonDecode(payloadJson);

    switch (action) {
      case 'createMedication':
        // The server id replaces the local one.
        return _remoteDataSource
            .createMedication(CreateMedicationModel.fromJson(payload));

      case 'updateMedication':
        await _remoteDataSource.updateMedication(
            entityId, UpdateMedicationModel.fromJson(payload));
        return null;

      case 'confirmMedication':
        await _remoteDataSource.confirmMedication(
            entityId, payload['section'] as String,
            date: payload['date'] as String?);
        return null;

      case 'deleteMedication':
        await _remoteDataSource.deleteMedication(entityId);
        return null;

      default:
        throw UnimplementedError('Unknown action $action for medication');
    }
  }

  @override
  Future<void> remapLocalId(String oldId, String newId) =>
      _db.transaction(() async {
        await _db.medicationsDao.updateMedicationId(oldId, newId);
        await _db.adherenceDao.updateLogsMedicationId(oldId, newId);
      });
}
