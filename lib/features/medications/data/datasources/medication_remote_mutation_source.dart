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
      case 'createMedication':
        final model = CreateMedicationModel.fromJson(payload);
        final res = await _remoteDataSource.createMedication(model);
        return res; // Returning the server ID so it can be remapped

      case 'updateMedication':
        final model = UpdateMedicationModel.fromJson(payload);
        // We do not remap on update, so returning null is fine.
        await _remoteDataSource.updateMedication(entityId, model);
        return null;

      case 'confirmMedication':
        final section = payload['section'] as String;
        final date = payload['date'] as String?;
        await _remoteDataSource.confirmMedication(entityId, section,
            date: date);
        return null;

      default:
        throw UnimplementedError('Unknown action $action for medication');
    }
  }
}
