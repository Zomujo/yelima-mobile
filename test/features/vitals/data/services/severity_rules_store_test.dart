import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelima/core/services/shared_prefs_service.dart';
import 'package:yelima/features/vitals/data/services/severity_rules_store.dart';
import 'package:yelima/features/vitals/domain/vital_severity_thresholds.dart';

import '../../../../helpers/fake_api.dart';

/// The table exactly as the server sends it (backend follow-up, L1).
Map<String, dynamic> serverTable({num elevatedFrom = 120}) => {
      'version': 'v-$elevatedFrom',
      'bloodPressure': {
        'unit': 'mmHg',
        'rules': [
          {
            'label': 'hypertensive_crisis',
            'any': [
              {'field': 'systolic', 'gte': 180},
              {'field': 'diastolic', 'gte': 120}
            ]
          },
          {
            'label': 'severe_hypotension',
            'any': [
              {'field': 'systolic', 'lt': 80},
              {'field': 'diastolic', 'lt': 50}
            ]
          },
          {
            'label': 'hypertensive',
            'any': [
              {'field': 'systolic', 'gte': 130},
              {'field': 'diastolic', 'gte': 80}
            ]
          },
          {
            'label': 'hypotensive',
            'any': [
              {'field': 'systolic', 'lt': 90},
              {'field': 'diastolic', 'lt': 60}
            ]
          },
          {
            'label': 'elevated',
            'any': [
              {'field': 'systolic', 'gte': elevatedFrom}
            ]
          },
          {'label': 'normal'}
        ]
      },
      'bloodSugar': {
        'unit': 'mmol/L',
        'rules': [
          {
            'label': 'critically_low',
            'any': [
              {'field': 'value', 'lt': 3.0}
            ]
          },
          {
            'label': 'low',
            'any': [
              {'field': 'value', 'lt': 3.9}
            ]
          },
          {
            'label': 'normal',
            'any': [
              {'field': 'value', 'lt': 7.3}
            ]
          },
          {
            'label': 'elevated',
            'any': [
              {'field': 'value', 'lt': 11.1}
            ]
          },
          {
            'label': 'high',
            'any': [
              {'field': 'value', 'lt': 13.9}
            ]
          },
          {'label': 'critically_high'}
        ]
      },
      'critical': ['critical'],
      'default': 'normal',
    };

void main() {
  const path = '/api/v1/client/severity-thresholds';
  late FakeApi api;
  late SharedPrefsService prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = SharedPrefsService(await SharedPreferences.getInstance());
    api = FakeApi();
  });

  test('the server table grades every boundary like the bundled one', () {
    final server = SeverityRules.fromJson(serverTable());
    const bundled = SeverityRules.bundled;
    for (var sys = 60; sys <= 200; sys++) {
      for (var dia = 40; dia <= 130; dia += 3) {
        expect(server.bloodPressure(sys, dia), bundled.bloodPressure(sys, dia),
            reason: '$sys/$dia');
      }
    }
    for (var tenths = 20; tenths <= 160; tenths++) {
      expect(server.bloodSugar(tenths / 10), bundled.bloodSugar(tenths / 10),
          reason: '${tenths / 10}');
    }
  });

  test('before any fetch, the bundled table is used', () {
    expect(SeverityRulesStore(api.client, prefs).current.version,
        SeverityRules.bundled.version);
  });

  test('a fetched table is used at once and kept for the next launch',
      () async {
    api.on('GET', path, FakeReply.ok(serverTable(elevatedFrom: 125)));
    final store = SeverityRulesStore(api.client, prefs);

    await store.refresh();

    expect(store.current.bloodPressure(122, 70), 'normal');
    final nextLaunch = SeverityRulesStore(FakeApi().client, prefs);
    expect(nextLaunch.current.version, 'v-125');
  });

  test('a broken or failed fetch keeps the current table', () async {
    api.on('GET', path, FakeReply.ok({'version': 'x'}));
    final store = SeverityRulesStore(api.client, prefs);
    await store.refresh();
    expect(store.current.version, SeverityRules.bundled.version);

    api.on('GET', path, FakeReply.error(500));
    await store.refresh();
    expect(store.current.version, SeverityRules.bundled.version);
  });
}
