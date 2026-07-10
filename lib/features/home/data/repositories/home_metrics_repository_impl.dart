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
    return ExceptionWrapper.runAsyncWithNetworkCheck<HomeMetricsEntity>(
      () async {
        List<VitalHistoryEntity> vitals = [];
        double? adherence;

        // Fetch remote vitals and adherence concurrently.
        final futures = await Future.wait([
          remoteDataSource
              .fetchVitalHistories()
              .catchError((_) => <VitalHistoryModel>[]),
          remoteDataSource
              .fetchMedicationAdherence()
              .catchError((_) => <String, dynamic>{})
        ]);

        final remoteVitals = futures[0] as List;
        final adherenceResponse = futures[1] as Map<String, dynamic>;

        // Fallback to local cache if remote vitals fetch fails.
        if (remoteVitals.isNotEmpty) {
          final models = remoteVitals.cast<VitalHistoryModel>().toList();
          await localDataSource.cacheVitalHistories(models);
          vitals = models;
        } else {
          vitals = await localDataSource.getCachedVitalHistories();
        }

        // Parse adherence data with local cache fallback.
        final data = adherenceResponse['data'];
        if (data is Map && data['rate'] != null) {
          final parsed = double.tryParse(data['rate'].toString());
          if (parsed != null) {
            adherence = parsed > 1 ? parsed / 100 : parsed;
            await localDataSource.cacheAdherence(adherence);
          }
        } else {
          adherence = await localDataSource.getCachedAdherence();
        }

        return Right(HomeMetricsModel.fromVitals(vitals, adherence));
      },
      connectivityService: connectivityService,
    );
  }

  @override
  AsyncResponse<void> saveVitalReading(VitalHistoryEntity entity) async {
    return ExceptionWrapper.runAsyncWithNetworkCheck<void>(
      () async {
        final body = {
          "vitalType": entity.vitalType,
          "value": entity.value,
          "unit": entity.unit,
          "recordedAt": entity.recordedAt?.toUtc().toIso8601String() ??
              DateTime.now().toUtc().toIso8601String(),
        };

        await remoteDataSource.saveVitalReading(body);

        final model = VitalHistoryModel(
          id: entity.id,
          vitalType: entity.vitalType,
          value: entity.value,
          unit: entity.unit,
          severity: entity.severity,
          vitalName: entity.vitalName,
          recordedAt: entity.recordedAt,
        );

        await localDataSource.appendVitalHistory(model);
        return const Right(null);
      },
      connectivityService: connectivityService,
    );
  }
}
