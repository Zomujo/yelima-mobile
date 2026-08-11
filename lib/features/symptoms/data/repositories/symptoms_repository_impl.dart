import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/db/app_database.dart';
import '../../domain/entities/symptom_entity.dart';
import '../../domain/repositories/symptoms_repository.dart';
import '../datasources/symptoms_remote_data_source.dart';

class SymptomsRepositoryImpl implements SymptomsRepository {
  final SymptomsRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;

  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  SymptomsRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
  });

  @override
  Future<Either<String, String>> createSymptom(String description) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    // 1. Instantly save to local DB for fast UI
    await db.symptomsDao.insertOrUpdateSymptom(
      SymptomsCompanion(
        id: drift.Value(tempId),
        description: drift.Value(description),
        onsetDate: drift.Value(now),
      ),
    );

    if (await connectivityService.isConnected) {
      try {
        final realId = await remoteDataSource.createSymptom(description);
        
        // Replace temp ID with real ID
        await db.symptomsDao.deleteSymptomById(tempId);
        await db.symptomsDao.insertOrUpdateSymptom(
          SymptomsCompanion(
            id: drift.Value(realId),
            description: drift.Value(description),
            onsetDate: drift.Value(now),
          ),
        );
        return Right(realId);
      } catch (e) {
        // Fallback to queue if remote fails despite connectivity
        await _queueCreation(tempId, description);
        return Right(tempId);
      }
    } else {
      // Offline, queue for sync
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
  Future<Either<String, List<SymptomEntity>>> getSymptoms({int page = 1, int pageSize = 10}) async {
    // Basic caching logic
    if (_lastFetchTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastFetchTime!) < _cacheDuration) {
        debugPrint("Skipping remote fetch for Symptoms. Cache is fresh.");
        return _fetchLocalSymptoms();
      }
    }

    if (await connectivityService.isConnected) {
      try {
        final remoteData = await remoteDataSource.getSymptoms(page: page, pageSize: pageSize);

        await db.transaction(() async {
          if (page == 1) {
            await db.symptomsDao.clearSymptoms();
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

        _lastFetchTime = DateTime.now();
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
      final entities = localSymptoms.map((s) => SymptomEntity(
        id: s.id,
        description: s.description,
        onsetDate: s.onsetDate,
      )).toList();

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
  Future<Either<String, void>> updateSymptom(String id, String description) async {
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
