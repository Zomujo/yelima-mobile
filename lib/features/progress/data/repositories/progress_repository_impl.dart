import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/db/app_database.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/guard.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/session_epoch.dart';
import '../../domain/entities/vital_trends.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';

/// [ProgressRepository] that keeps the last trend of each range on the phone.
///
/// Trends are stored as JSON rows in the vitals table; its refresh leaves TREND rows alone.
class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({
    required ProgressRemoteDataSource remoteDataSource,
    required this.connectivityService,
    required this.db,
    required this.session,
  }) : _remote = remoteDataSource;

  final ProgressRemoteDataSource _remote;
  final ConnectivityService connectivityService;
  final AppDatabase db;
  final SessionEpoch session;

  static String _bpKey(ChartDateRange r) => 'bp_trend_cache_${r.name}';
  static String _sugarKey(ChartDateRange r) =>
      'vital_trend_cache_bloodSugar_${r.name}';

  @override
  AsyncResult<BPTrend> getCachedBPTrend(ChartDateRange range) =>
      guard(() => _cached(_bpKey(range), BPTrend.fromJson));

  @override
  AsyncResult<VitalTrend> getCachedSugarTrend(ChartDateRange range) =>
      guard(() => _cached(_sugarKey(range), VitalTrend.fromJson));

  @override
  AsyncResult<BPTrend> getBPTrend(ChartDateRange range) => _fetch(
      key: _bpKey(range),
      type: 'PROGRESS_BP_TREND',
      fetch: () => _remote.getBPTrend(dateRange: range.name),
      toJson: (t) => t.toJson(),
      fromJson: BPTrend.fromJson);

  @override
  AsyncResult<VitalTrend> getSugarTrend(ChartDateRange range) => _fetch(
      key: _sugarKey(range),
      type: 'PROGRESS_VITAL_TREND',
      fetch: () =>
          _remote.getVitalTrend(vitalType: 'bloodSugar', dateRange: range.name),
      toJson: (t) => t.toJson(),
      fromJson: VitalTrend.fromJson);

  /// Fetches and caches a trend; when that fails, the cached one, else the original failure.
  AsyncResult<T> _fetch<T>({
    required String key,
    required String type,
    required Future<T> Function() fetch,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
  }) =>
      guard(() async {
        try {
          if (!await connectivityService.isConnected) {
            throw const NetworkFailure();
          }
          final epoch = session.current;
          final trend = await fetch();
          session.ensure(epoch);
          await db.vitalsDao.insertVitals([
            VitalHistoriesCompanion(
              id: Value(key),
              vitalType: Value(type),
              vitalName: Value(key),
              value: Value(jsonEncode(toJson(trend))),
              unit: const Value('json'),
              severity: const Value('normal'),
              recordedAt: Value(clock.now()),
            )
          ]);
          return trend;
        } catch (_) {
          final cached = await _cachedOrNull(key, fromJson);
          if (cached != null) return cached;
          rethrow;
        }
      });

  Future<T> _cached<T>(
          String key, T Function(Map<String, dynamic>) fromJson) async =>
      await _cachedOrNull(key, fromJson) ?? (throw const NotFoundFailure());

  Future<T?> _cachedOrNull<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    final row = (await db.vitalsDao.getAllVitals())
        .where((v) => v.id == key)
        .firstOrNull;
    return row == null ? null : fromJson(jsonDecode(row.value));
  }
}
