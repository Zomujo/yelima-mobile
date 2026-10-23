import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/db/app_database.dart';
import '../../domain/entities/symptom_entity.dart';
import '../../domain/repositories/symptoms_repository.dart';
import '../datasources/symptoms_remote_data_source.dart';
import 'package:clock/clock.dart';
import '../../../../core/services/session_epoch.dart';

class SymptomsRepositoryImpl implements SymptomsRepository {
  final SymptomsRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;

  DateTime? _lastFetchTime;
  int? _lastFetchEpoch;
  static const Duration _cacheDuration = Duration(minutes: 5);

  SymptomsRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
    required this.session,
  });

  final SessionEpoch session;

  @override
  Future<Either<String, String>> createSymptom(String description) async {
    final tempId = 'temp_${clock.now().millisecondsSinceEpoch}';
    final now = clock.now();

    final local = SymptomsCompanion(
      id: drift.Value(tempId),
      description: drift.Value(description),
      onsetDate: drift.Value(now),
    );

    if (!await connectivityService.isConnected) {
      // Saved and queued in one step, so a crash can't keep one without the other.
      await db.transaction(() async {
        await db.symptomsDao.insertOrUpdateSymptom(local);
        await _queueCreation(tempId, description);
      });
      return Right(tempId);
    }

    // Saved first so the UI updates instantly while the request runs.
    await db.symptomsDao.insertOrUpdateSymptom(local);
    try {
      final realId = await remoteDataSource.createSymptom(description);
      await db.transaction(() async {
        await db.symptomsDao.deleteSymptomById(tempId);
        await db.symptomsDao
            .insertOrUpdateSymptom(local.copyWith(id: drift.Value(realId)));
      });
      return Right(realId);
    } catch (e) {
      // Reachable but the request failed: queue it to retry later.
      await _queueCreation(tempId, description);
      return Right(tempId);
    }
  }

  Future<void> _queueCreation(String id, String description) async {
    await db.pendingMutationsDao.queueMutation(
      entityId: id,
      entityType: 'symptom',
      action: 'create',
      payload: {'description': description},
    );
  }

  @override
  Future<Either<String, List<SymptomEntity>>> getSymptoms(
      {int page = 1, int pageSize = 10}) async {
    // Basic caching logic
    // A fetch from an earlier session (another user) never counts as fresh.
    if (_lastFetchTime != null && session.isCurrent(_lastFetchEpoch ?? -1)) {
      final now = clock.now();
      if (now.difference(_lastFetchTime!) < _cacheDuration) {
        debugPrint("Skipping remote fetch for Symptoms. Cache is fresh.");
        return _fetchLocalSymptoms();
      }
    }

    if (await connectivityService.isConnected) {
      try {
        final epoch = session.current;
        final remoteData =
            await remoteDataSource.getSymptoms(page: page, pageSize: pageSize);
        session.ensure(epoch);

        await db.transaction(() async {
          if (page == 1) {
            // Symptoms still waiting to sync aren't on the server yet, so keep them.
            final pending =
                await db.pendingMutationsDao.getEntityIdsOfType('symptom');
            await db.symptomsDao.clearSymptoms(keepIds: pending);
          }

          for (var row in remoteData) {
            await db.symptomsDao.insertOrUpdateSymptom(
              SymptomsCompanion(
                id: drift.Value(row.id),
                description: drift.Value(row.description),
                onsetDate: drift.Value(row.onsetDate),
              ),
            );
          }
        });

        _lastFetchTime = clock.now();
        _lastFetchEpoch = epoch;
        // Fallback to local DB read so we include locally pending offline creations
        return _fetchLocalSymptoms();
      } catch (e) {
        return _fetchLocalSymptoms();
      }
    } else {
      return _fetchLocalSymptoms();
    }
  }

  Future<Either<String, List<SymptomEntity>>> _fetchLocalSymptoms() async {
    try {
      final localSymptoms = await db.symptomsDao.getAllSymptoms();
      final entities = localSymptoms
          .map((s) => SymptomEntity(
                id: s.id,
                description: s.description,
                onsetDate: s.onsetDate,
              ))
          .toList();

      return Right(entities);
    } catch (e) {
      return const Left('Failed to load cached symptoms');
    }
  }

  @override
  Future<Either<String, SymptomEntity>> getSymptomById(String id) async {
    // Left as remote only for now or could query local db
    try {
      final symptom = await remoteDataSource.getSymptomById(id);
      return Right(symptom);
    } on ApiException catch (e) {
      return Left(e.message ?? 'Unknown error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateSymptom(
      String id, String description) async {
    try {
      await remoteDataSource.updateSymptom(id, description);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message ?? 'Unknown error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteSymptom(String id) async {
    try {
      await remoteDataSource.deleteSymptom(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message ?? 'Unknown error');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
