import 'dart:convert';
import '../../../../core/api/i_remote_mutation.dart';
import 'medication_remote_datasource.dart';
import '../models/create_medication_model.dart';
import '../models/update_medication_model.dart';

class MedicationRemoteMutationSource implements IRemoteMutationSource {
  final MedicationRemoteDataSource _remoteDataSource;

  MedicationRemoteMutationSource(this._remoteDataSource);

  @override
  Future<String?> syncMutation({
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) async {
    final payload = jsonDecode(payloadJson);

    switch (action) {
      case 'create_medication':
        final model = CreateMedicationModel.fromJson(payload);
        final newServerId = await _remoteDataSource.createMedication(model);
        return newServerId; // Return new server ID to map locally
      case 'update_medication':
        final model = UpdateMedicationModel.fromJson(payload);
        await _remoteDataSource.updateMedication(entityId, model);
        return null;
      case 'confirm':
        // Confirm mutation has payload { "medicationId": "...", "section": "...", "date": "..." }
        final section = payload['section'] as String;
        final date = payload['date'] as String?;
        await _remoteDataSource.confirmMedication(entityId, section, date: date);
        return null;
      default:
        throw UnimplementedError('Unknown action $action for medication');
    }
  }
}
