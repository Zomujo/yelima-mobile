import 'dart:async';
import 'package:fpdart/fpdart.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/custom_types.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../domain/entities/vital_history_entity.dart';
import '../../domain/repositories/home_metrics_repository.dart';
import '../datasources/home_metrics_remote_datasource.dart';
import '../datasources/home_metrics_local_datasource.dart';
import '../models/home_metrics_model.dart';
import '../models/vital_history_model.dart';
import '../../../../core/db/app_database.dart';
import 'package:get_it/get_it.dart';

class HomeMetricsRepositoryImpl implements HomeMetricsRepository {
  final HomeMetricsRemoteDataSource remoteDataSource;
  final HomeMetricsLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  HomeMetricsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  AsyncResponse<HomeMetricsEntity> getCachedHomeMetrics() async {
    try {
      final vitals = await localDataSource.getCachedVitalHistories();
      final adherence = await localDataSource.getCachedAdherence();
      return Right(HomeMetricsModel.fromVitals(vitals, adherence));
    } catch (e) {
      return Left('Failed to fetch cached home metrics: $e');
    }
  }

  @override
  AsyncResponse<HomeMetricsEntity> getHomeMetrics() async {
    return ExceptionWrapper.runAsync<HomeMetricsEntity>(
      () async {
        List<VitalHistoryEntity> vitals = [];
        double? adherence;

        // Fetch remote vitals and adherence concurrently.
        bool vitalsFetchFailed = false;
        bool adherenceFetchFailed = false;

        final futures = await Future.wait([
          remoteDataSource.fetchVitalHistories().catchError((_) {
            vitalsFetchFailed = true;
            return <VitalHistoryModel>[];
          }),
          remoteDataSource.fetchMedicationAdherence().catchError((_) {
            adherenceFetchFailed = true;
            return <String, dynamic>{};
          })
        ]);

        final remoteVitals = futures[0] as List;
        final adherenceResponse = futures[1] as Map<String, dynamic>;

        // Fallback to local cache if remote vitals fetch actually failed.
        if (!vitalsFetchFailed) {
          final models = remoteVitals.cast<VitalHistoryModel>().toList();
          await localDataSource.cacheVitalHistories(models);
          vitals = models;
        } else {
          vitals = await localDataSource.getCachedVitalHistories();
        }

        // Parse adherence data with local cache fallback if fetch failed.
        if (!adherenceFetchFailed) {
          final data = adherenceResponse['data'];
          if (data is Map && data['rate'] != null) {
            final parsed = double.tryParse(data['rate'].toString());
            if (parsed != null) {
              adherence = parsed > 1 ? parsed / 100 : parsed;
              await localDataSource.cacheAdherence(adherence);
            }
          } else {
            await localDataSource.clearCachedAdherence();
            adherence = null;
          }
        } else {
          adherence = await localDataSource.getCachedAdherence();
        }

        return Right(HomeMetricsModel.fromVitals(vitals, adherence));
      },
      operationName: 'HomeMetricsRepositoryImpl.getHomeMetrics',
    );
  }

  @override
  AsyncResponse<void> saveVitalReading(VitalHistoryEntity entity) async {
    return ExceptionWrapper.runAsync<void>(
      () async {
        final isConnected = await connectivityService.isConnected;

        final body = {
          "vitalType": entity.vitalType,
          "value": entity.value,
          "unit": entity.unit,
          "recordedAt": entity.recordedAt?.toUtc().toIso8601String() ??
              DateTime.now().toUtc().toIso8601String(),
        };

        final localId = entity.id.isEmpty ? 'offline_vital_${DateTime.now().millisecondsSinceEpoch}' : entity.id;

        final model = VitalHistoryModel(
          id: localId,
          vitalType: entity.vitalType,
          value: entity.value,
          unit: entity.unit,
          severity: entity.severity,
          vitalName: entity.vitalName,
          recordedAt: entity.recordedAt ?? DateTime.now(),
        );

        if (!isConnected) {
          await localDataSource.appendVitalHistory(model);
          final db = GetIt.instance<AppDatabase>();
          await db.pendingMutationsDao.queueMutation(
            entityId: localId,
            entityType: 'vital_history',
            action: 'saveVitalReading',
            payload: body,
          );
          try {
                      } catch (_) {}
          return const Right(null);
        }

        try {
          await remoteDataSource.saveVitalReading(body);
          // Only append to local cache if successful to avoid duplicating when remote fetch happens next
          await localDataSource.appendVitalHistory(model);
        } catch (e) {
          await localDataSource.appendVitalHistory(model);
          final db = GetIt.instance<AppDatabase>();
          await db.pendingMutationsDao.queueMutation(
            entityId: localId,
            entityType: 'vital_history',
            action: 'saveVitalReading',
            payload: body,
          );
          if (e is ApiException && (e.code == '401' || e.code == '403')) {
            rethrow;
          }
        }

        return const Right(null);
      },
      operationName: 'HomeMetricsRepositoryImpl.saveVitalReading',
    );
  }
}
