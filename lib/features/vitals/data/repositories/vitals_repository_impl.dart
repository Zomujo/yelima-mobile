import 'package:clock/clock.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/guard.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/recent_fetches.dart';
import '../../../../core/services/session_epoch.dart';
import '../../domain/entities/reading_form.dart';
import '../../domain/entities/vital_history_entity.dart';
import '../../domain/reading_limits.dart';
import '../../domain/repositories/vitals_repository.dart';
import '../../domain/vital_severity_thresholds.dart';
import '../datasources/vitals_remote_datasource.dart';
import '../models/vital_history_model.dart';

/// Offline-first [VitalsRepository] backed by the local database and the API.
class VitalsRepositoryImpl implements VitalsRepository {
  VitalsRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.session,
    required this.db,
    this.severityRules = _bundled,
    RecentFetches? recent,
  }) : recent = recent ?? RecentFetches(window: Duration.zero);

  /// Skips a download made in the last minute.
  final RecentFetches recent;

  final VitalsRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final SessionEpoch session;
  final AppDatabase db;

  /// The grading table in use; the server's copy once fetched.
  final SeverityRules Function() severityRules;

  static SeverityRules _bundled() => SeverityRules.bundled;
  static const _type = 'vital_history';

  /// Older versions kept cache and trend rows in the same table.
  static bool _isReading(VitalHistory row) {
    final type = row.vitalType.toUpperCase();
    return !type.contains('CACHE') && !type.contains('TREND');
  }

  @override
  Stream<List<VitalHistoryEntity>> watchReadings() =>
      db.vitalsDao.watchAllVitals().map((rows) =>
          rows.where(_isReading).map(VitalHistoryModel.fromDrift).toList());

  @override
  Stream<LatestVitals> watchLatest() => watchReadings().map(LatestVitals.from);

  @override
  AsyncResult<void> refresh() => guardOnline(
      connectivityService,
      () => recent.share(_type, () async {
            if (recent.isFresh(_type)) return;
            final epoch = session.current;
            final remote = await remoteDataSource.fetchVitalHistories();
            session.ensure(epoch);
            // Readings still waiting to sync aren't on the server yet, so keep them.
            final unsent =
                await db.pendingMutationsDao.getEntityIdsOfType(_type);
            await db.transaction(() async {
              await db.vitalsDao.clearVitals(keepIds: unsent);
              await db.vitalsDao
                  .insertVitals([for (final m in remote) m.toDrift()]);
            });
            recent.markFetched(_type);
          }));

  @override
  AsyncResult<VitalSeverity> saveReading(ReadingForm form) => guard(() async {
        if (form.problem case final problem?) throw ReadingFailure(problem);
        // A new reading changes the readings and the trends.
        recent.clear();
        final reading =
            form.toReading(const Uuid().v4(), rules: severityRules());
        final model = VitalHistoryModel.fromEntity(reading);
        final body = {
          'vitalType': model.vitalType,
          'value': model.value,
          'recordedAt':
              (model.recordedAt ?? clock.now()).toUtc().toIso8601String(),
        };

        Object? error;
        if (await connectivityService.isConnected) {
          try {
            await remoteDataSource.saveVitalReading(body,
                idempotencyKey: model.id);
            await db.vitalsDao.insertVitals([model.toDrift()]);
            return reading.grade;
          } catch (e) {
            error = e;
          }
        }
        // Saved and queued in one step, so a crash can't keep one without the other.
        await db.transaction(() async {
          await db.vitalsDao.insertVitals([model.toDrift()]);
          await db.pendingMutationsDao.queueMutation(
              entityId: model.id,
              entityType: _type,
              action: 'saveVitalReading',
              payload: body);
        });
        // Queued either way; only a lost login is reported.
        if (error != null && AppFailure.from(error) is UnauthorizedFailure) {
          throw error;
        }
        return reading.grade;
      });
}
