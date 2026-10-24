import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../domain/vital_severity_thresholds.dart';

/// The server's severity table, fetched at each sign-in and kept between launches.
/// Until a copy has arrived, or if one is broken, readings use the bundled table.
class SeverityRulesStore implements SessionLifecycleHandler {
  SeverityRulesStore(this._api, this._prefs);

  final APIClient _api;
  final SharedPrefsService _prefs;
  static const _key = 'severity_rules';

  SeverityRules? _rules;

  /// The table to grade with now.
  SeverityRules get current => _rules ??= _saved() ?? SeverityRules.bundled;

  SeverityRules? _saved() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return SeverityRules.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  /// Fetches the latest table; on any failure the current one stays.
  Future<void> refresh() async {
    try {
      final data =
          (await _api.get('/api/v1/client/severity-thresholds'))['data']
              as Map<String, dynamic>;
      final rules = SeverityRules.fromJson(data);
      if (rules.version == current.version) return;
      _rules = rules;
      await _prefs.setString(_key, jsonEncode(data));
    } catch (e) {
      debugPrint('SeverityRulesStore: keeping the current table: $e');
    }
  }

  @override
  String get serviceName => 'SeverityRulesStore';

  /// Not awaited, so sign-in never waits on it.
  @override
  Future<void> onSessionStarted(String userId) async => unawaited(refresh());

  @override
  Future<void> onSessionEnded() async {}
}
