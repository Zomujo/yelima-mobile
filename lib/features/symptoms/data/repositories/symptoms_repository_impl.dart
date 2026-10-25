import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/db/app_database.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/guard.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/recent_fetches.dart';
import '../../../../core/services/session_epoch.dart';
import '../../domain/entities/symptom_entity.dart';
import '../../domain/repositories/symptoms_repository.dart';
import '../datasources/symptoms_remote_data_source.dart';

/// Offline-first [SymptomsRepository] backed by the local database and the API.
class SymptomsRepositoryImpl implements SymptomsRepository {
  SymptomsRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
    required this.session,
    RecentFetches? recent,
  }) : recent = recent ?? RecentFetches(window: Duration.zero);

  final SymptomsRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;
  final SessionEpoch session;

  /// Skips a download made in the last minute.
  final RecentFetches recent;

  static const _type = 'symptom';

  @override
  Stream<List<SymptomEntity>> watchSymptoms() =>
      db.symptomsDao.watchAllSymptoms().map((rows) => [
            for (final s in rows)
              SymptomEntity(
                  id: s.id, description: s.description, onsetDate: s.onsetDate)
          ]);

  @override
  AsyncResult<void> refresh({bool force = false}) => guardOnline(
      connectivityService,
      () => recent.share(_type, () async {
            if (!force && recent.isFresh(_type)) return;
            final epoch = session.current;
            final remote = await remoteDataSource.getSymptoms();
            session.ensure(epoch);
            await db.transaction(() async {
              // Symptoms still waiting to sync aren't on the server yet, so keep them.
              await db.symptomsDao.clearSymptoms(
                  keepIds:
                      await db.pendingMutationsDao.getEntityIdsOfType(_type));
              for (final s in remote) {
                await db.symptomsDao.insertOrUpdateSymptom(
                    _row(s.id, s.description, s.onsetDate));
              }
            });
            recent.markFetched(_type);
          }));

  @override
  AsyncResult<String> createSymptom(String description) => guard(() async {
        recent.clear();
        final now = clock.now();
        final tempId = 'temp_${now.millisecondsSinceEpoch}';
        final row = _row(tempId, description, now);

        if (await connectivityService.isConnected) {
          // Saved first so the list updates at once while the request runs.
          await db.symptomsDao.insertOrUpdateSymptom(row);
          try {
            final id = await remoteDataSource.createSymptom(description,
                onsetDate: now, idempotencyKey: tempId);
            await db.symptomsDao.updateSymptomId(tempId, id);
            return id;
          } catch (_) {
            // Reachable but the request failed: retry later.
            await _queue(tempId, description, now);
            return tempId;
          }
        }
        // Saved and queued in one step, so a crash can't keep one without the other.
        await db.transaction(() async {
          await db.symptomsDao.insertOrUpdateSymptom(row);
          await _queue(tempId, description, now);
        });
        return tempId;
      });

  static SymptomsCompanion _row(String id, String description, DateTime at) =>
      SymptomsCompanion(
          id: Value(id), description: Value(description), onsetDate: Value(at));

  Future<void> _queue(String id, String description, DateTime onsetDate) =>
      db.pendingMutationsDao.queueMutation(
          entityId: id,
          entityType: _type,
          action: 'create',
          payload: {
            'description': description,
            'onsetDate': onsetDate.toUtc().toIso8601String(),
          });
}
