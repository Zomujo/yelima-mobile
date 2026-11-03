import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/db/app_database.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/guard.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/recent_fetches.dart';
import '../../../../core/services/session_epoch.dart';
import '../../domain/entities/vital_trends.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';

/// [ProgressRepository] that keeps the last trend of each range on the phone.
///
/// Trends are stored as JSON rows in the vitals table; its refresh leaves TREND rows alone.
/// Readings saved on the phone are added to every trend, so the charts match home
/// even offline or before the server has them.
class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({
    required ProgressRemoteDataSource remoteDataSource,
    required this.connectivityService,
    required this.db,
    required this.session,
    RecentFetches? recent,
  })  : _remote = remoteDataSource,
        recent = recent ?? RecentFetches(window: Duration.zero);

  final ProgressRemoteDataSource _remote;
  final ConnectivityService connectivityService;
  final AppDatabase db;
  final SessionEpoch session;

  /// Skips a download made in the last minute.
  final RecentFetches recent;

  static String _bpKey(ChartDateRange r) => 'bp_trend_cache_${r.name}';
  static String _sugarKey(ChartDateRange r) =>
      'vital_trend_cache_bloodSugar_${r.name}';

  static const _noBP = BPTrend(labels: [], systolic: [], diastolic: []);
  static const _noSugar = VitalTrend(labels: [], values: []);

  @override
  AsyncResult<BPTrend> getCachedBPTrend(ChartDateRange range) =>
      guard(() async =>
          _withBP(range, await _cachedOrNull(_bpKey(range), BPTrend.fromJson)));

  @override
  AsyncResult<VitalTrend> getCachedSugarTrend(ChartDateRange range) =>
      guard(() async => _withSugar(
          range, await _cachedOrNull(_sugarKey(range), VitalTrend.fromJson)));

  @override
  AsyncResult<BPTrend> getBPTrend(ChartDateRange range) => _fetch(
      key: _bpKey(range),
      type: 'PROGRESS_BP_TREND',
      fetch: () => _remote.getBPTrend(dateRange: range.name),
      toJson: (t) => t.toJson(),
      fromJson: BPTrend.fromJson,
      withPhone: (t) => _withBP(range, t));

  @override
  AsyncResult<VitalTrend> getSugarTrend(ChartDateRange range) => _fetch(
      key: _sugarKey(range),
      type: 'PROGRESS_VITAL_TREND',
      fetch: () =>
          _remote.getVitalTrend(vitalType: 'bloodSugar', dateRange: range.name),
      toJson: (t) => t.toJson(),
      fromJson: VitalTrend.fromJson,
      withPhone: (t) => _withSugar(range, t));

  Future<BPTrend> _withBP(ChartDateRange range, BPTrend? trend) async =>
      (trend ?? _noBP).withReadings(
          await _phoneReadings('bloodPressure'), range.since(clock.now()));

  Future<VitalTrend> _withSugar(
          ChartDateRange range, VitalTrend? trend) async =>
      (trend ?? _noSugar).withReadings(
          await _phoneReadings('bloodSugar'), range.since(clock.now()));

  Future<List<PhoneReading>> _phoneReadings(String type) async => [
        for (final v in await db.vitalsDao.getAllVitals())
          if (v.vitalType == type && v.recordedAt != null)
            (v.recordedAt!, v.value),
      ];

  /// Fetches and caches a trend, adding the phone's readings; when that fails,
  /// the cached one, or the phone's readings alone, else the original failure.
  AsyncResult<T> _fetch<T extends TrendLabels>({
    required String key,
    required String type,
    required Future<T> Function() fetch,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
    required Future<T> Function(T?) withPhone,
  }) =>
      guard(() => recent.share(key, () async {
            if (recent.isFresh(key)) {
              if (await _cachedOrNull(key, fromJson) case final cached?) {
                return withPhone(cached);
              }
            }
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
              recent.markFetched(key);
              return withPhone(trend);
            } catch (_) {
              final cached = await _cachedOrNull(key, fromJson);
              final merged = await withPhone(cached);
              if (cached != null || merged.labels.isNotEmpty) return merged;
              rethrow;
            }
          }));

  Future<T?> _cachedOrNull<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    final row = (await db.vitalsDao.getAllVitals())
        .where((v) => v.id == key)
        .firstOrNull;
    return row == null ? null : fromJson(jsonDecode(row.value));
  }
}
