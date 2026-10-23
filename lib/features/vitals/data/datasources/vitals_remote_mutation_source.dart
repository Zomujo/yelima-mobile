import 'dart:convert';

import '../../../../core/api/i_remote_mutation.dart';
import '../../../../core/db/app_database.dart';
import 'vitals_remote_datasource.dart';

/// Replays queued readings to the server.
class VitalsRemoteMutationSource implements IRemoteMutationSource {
  VitalsRemoteMutationSource(this._remote, this._db);

  final VitalsRemoteDataSource _remote;
  final AppDatabase _db;

  @override
  Future<String?> syncMutation({
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) async {
    if (action != 'saveVitalReading') {
      throw UnimplementedError('Unknown action $action for vital_history');
    }
    // The server's id replaces the local one.
    return await _remote.saveVitalReading(jsonDecode(payloadJson),
            idempotencyKey: entityId) ??
        entityId;
  }

  @override
  Future<void> remapLocalId(String oldId, String newId) =>
      _db.vitalsDao.updateVitalId(oldId, newId);
}
