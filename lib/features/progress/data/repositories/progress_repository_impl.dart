import 'dart:convert';
import 'dart:isolate';
import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/custom_types.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/db/app_database.dart';
import '../../domain/entities/vital_trends.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';
import '../utils/progress_isolate_parsers.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressRemoteDataSource _remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;

  ProgressRepositoryImpl({
    required ProgressRemoteDataSource remoteDataSource,
    required this.connectivityService,
    required this.db,
  }) : _remoteDataSource = remoteDataSource;

  @override
  AsyncResponse<BPTrend> getCachedBPTrend({required String dateRange}) =>
      _fetchLocalBPTrend(dateRange);

  @override
  AsyncResponse<VitalTrend> getCachedVitalTrend(
          {required String vitalType, required String dateRange}) =>
      _fetchLocalVitalTrend(vitalType, dateRange);

  @override
  AsyncResponse<BPTrend> getBPTrend({required String dateRange}) {
    return ExceptionWrapper.runAsync<BPTrend>(
      () async {
        try {
          if (!await connectivityService.isConnected) {
            throw const NetworkException();
          }
          final result =
              await _remoteDataSource.getBPTrend(dateRange: dateRange);

          final trendJson = jsonEncode({
            'labels': result.labels,
            'systolic': result.systolic,
            'diastolic': result.diastolic,
          });

          final cacheModel = VitalHistoriesCompanion(
            id: drift.Value('bp_trend_cache_$dateRange'),
            vitalType: const drift.Value('PROGRESS_BP_TREND'),
            vitalName: drift.Value('BP Trend $dateRange'),
            value: drift.Value(trendJson),
            unit: const drift.Value('json'),
            severity: const drift.Value('normal'),
            recordedAt: drift.Value(DateTime.now()),
          );
          await db.vitalsDao.insertVitals([cacheModel]);

          return right(result);
        } catch (_) {
          final localResult = await _fetchLocalBPTrend(dateRange);
          return localResult;
        }
      },
      operationName: 'ProgressRepositoryImpl.getBPTrend',
    );
  }

  AsyncResponse<BPTrend> _fetchLocalBPTrend(String dateRange) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      final cacheKey = 'bp_trend_cache_$dateRange';
      final cachedVital = vitals.where((v) => v.id == cacheKey).firstOrNull;

      if (cachedVital != null) {
        final trend = await Isolate.run(() => parseBpTrend(cachedVital.value));
        return right(trend);
      }
      return left(
          'No offline data available for BP trend. Please connect to the internet to fetch it.');
    } catch (e) {
      return left('Failed to load cached BP trend.');
    }
  }

  @override
  AsyncResponse<VitalTrend> getVitalTrend(
      {required String vitalType, required String dateRange}) {
    return ExceptionWrapper.runAsync<VitalTrend>(
      () async {
        try {
          if (!await connectivityService.isConnected) {
            throw const NetworkException();
          }
          final result = await _remoteDataSource.getVitalTrend(
              vitalType: vitalType, dateRange: dateRange);

          final trendJson = jsonEncode({
            'labels': result.labels,
            'values': result.values,
          });

          final cacheModel = VitalHistoriesCompanion(
            id: drift.Value('vital_trend_cache_${vitalType}_$dateRange'),
            vitalType: const drift.Value('PROGRESS_VITAL_TREND'),
            vitalName: drift.Value('Vital Trend $vitalType $dateRange'),
            value: drift.Value(trendJson),
            unit: const drift.Value('json'),
            severity: const drift.Value('normal'),
            recordedAt: drift.Value(DateTime.now()),
          );
          await db.vitalsDao.insertVitals([cacheModel]);

          return right(result);
        } catch (_) {
          final localResult = await _fetchLocalVitalTrend(vitalType, dateRange);
          return localResult;
        }
      },
      operationName: 'ProgressRepositoryImpl.getVitalTrend',
    );
  }

  AsyncResponse<VitalTrend> _fetchLocalVitalTrend(
      String vitalType, String dateRange) async {
    try {
      final vitals = await db.vitalsDao.getAllVitals();
      final cacheKey = 'vital_trend_cache_${vitalType}_$dateRange';
      final cachedVital = vitals.where((v) => v.id == cacheKey).firstOrNull;

      if (cachedVital != null) {
        final trend = await Isolate.run(() => parseVitalTrend(cachedVital.value));
        return right(trend);
      }
      return left(
          'No offline data available for $vitalType trend. Please connect to the internet to fetch it.');
    } catch (e) {
      return left('Failed to load cached $vitalType trend.');
    }
  }
}
