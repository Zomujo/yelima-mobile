import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:yelima/core/services/connectivity_service.dart';
import 'package:yelima/core/utils/custom_types.dart';
import 'package:yelima/core/exceptions/exceptions.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/repositories/vitals_repository.dart';
import 'package:yelima/features/vitals/data/datasources/vitals_remote_datasource.dart';
import 'package:yelima/features/vitals/data/datasources/vitals_local_datasource.dart';
import 'package:yelima/features/vitals/data/models/home_metrics_model.dart';
import 'package:yelima/features/vitals/data/models/vital_history_model.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:clock/clock.dart';
import 'package:yelima/core/services/session_epoch.dart';

class VitalsRepositoryImpl implements VitalsRepository {
  final VitalsRemoteDataSource remoteDataSource;
  final VitalsLocalDataSource localDataSource;
  final ConnectivityService connectivityService;
  final SessionEpoch session;
  final AppDatabase db;

  VitalsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
    required this.session,
    required this.db,
  });

  /// Saves the reading locally and queues it in one step, so a crash can't keep one without the other.
  Future<void> _saveAndQueue(
          VitalHistoryModel model, Map<String, dynamic> body) =>
      db.transaction(() async {
        await localDataSource.appendVitalHistory(model);
        await db.pendingMutationsDao.queueMutation(
          entityId: model.id,
          entityType: 'vital_history',
          action: 'saveVitalReading',
          payload: body,
        );
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

        final epoch = session.current;
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

        session.ensure(epoch);
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
      operationName: 'VitalsRepositoryImpl.getHomeMetrics',
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
          "severity": entity.severity,
          if (entity.vitalSubType != null) "vitalSubType": entity.vitalSubType,
          "recordedAt": entity.recordedAt?.toUtc().toIso8601String() ??
              clock.now().toUtc().toIso8601String(),
        };

        final localId = entity.id.isEmpty
            ? 'offline_vital_${clock.now().millisecondsSinceEpoch}'
            : entity.id;

        final model = VitalHistoryModel(
          id: localId,
          vitalType: entity.vitalType,
          value: entity.value,
          unit: entity.unit,
          severity: entity.severity,
          vitalName: entity.vitalName,
          vitalSubType: entity.vitalSubType,
          recordedAt: entity.recordedAt ?? clock.now(),
        );

        if (!isConnected) {
          await _saveAndQueue(model, body);
          return const Right(null);
        }

        try {
          await remoteDataSource.saveVitalReading(body);
          // Only append to local cache if successful to avoid duplicating when remote fetch happens next
          await localDataSource.appendVitalHistory(model);
        } catch (e) {
          await _saveAndQueue(model, body);
          if (e is ApiException && (e.code == '401' || e.code == '403')) {
            rethrow;
          }
        }

        return const Right(null);
      },
      operationName: 'VitalsRepositoryImpl.saveVitalReading',
    );
  }

  @override
  Stream<List<VitalHistoryEntity>> watchVitalHistories() {
    return db.vitalsDao.watchAllVitals().map((vitals) {
      return vitals.where((v) {
        final type = v.vitalType.toUpperCase();
        return !type.contains("CACHE") && !type.contains("TREND");
      }).map((v) {
        return VitalHistoryModel(
          id: v.id,
          vitalType: v.vitalType,
          value: v.value,
          unit: v.unit,
          severity: v.severity,
          vitalName: v.vitalName,
          vitalSubType: v.vitalSubType,
          recordedAt: v.recordedAt ?? clock.now(),
        );
      }).toList();
    });
  }
}
