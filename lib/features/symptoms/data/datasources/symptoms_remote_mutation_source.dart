import 'dart:convert';

import '../../../../core/api/i_remote_mutation.dart';
import '../../../../core/db/app_database.dart';
import 'symptoms_remote_data_source.dart';

/// Replays queued symptom reports to the server.
class SymptomsRemoteMutationSource implements IRemoteMutationSource {
  SymptomsRemoteMutationSource(this._remote, this._db);

  final SymptomsRemoteDataSource _remote;
  final AppDatabase _db;

  @override
  Future<String?> syncMutation({
    required String entityId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) {
    if (action != 'create') {
      throw UnimplementedError('Unknown action $action for symptom');
    }
    // The server id replaces the temporary one.
    return _remote.createSymptom(jsonDecode(payloadJson)['description']);
  }

  @override
  Future<void> remapLocalId(String oldId, String newId) =>
      _db.symptomsDao.updateSymptomId(oldId, newId);
}
