import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/medications/data/datasources/medication_remote_datasource.dart';
import 'package:yelima/features/medications/data/datasources/medication_remote_mutation_source.dart';

import '../../../helpers/fake_api.dart';
import '../../../helpers/fakes.dart';

void main() {
  test('a queued dose confirmation is sent for the day it was taken', () async {
    final api = FakeApi()
      ..on('PUT', '/api/v1/client/medications/med-1/confirm',
          FakeReply.ok(null));
    final db = testDb();
    addTearDown(db.close);
    final source = MedicationRemoteMutationSource(
        MedicationRemoteDataSource(apiClient: api.client), db);

    await source.syncMutation(
      entityId: 'med-1',
      action: 'confirmMedication',
      payloadJson: jsonEncode({'section': 'MORNING', 'date': '2026-10-23'}),
      createdAt: clock.now(),
    );

    final sent = api.sent('PUT', '/api/v1/client/medications/med-1/confirm');
    expect(sent.single.queryParameters,
        {'section': 'MORNING', 'scheduledFor': '2026-10-23'});
  });

  test('a queued new medication carries its local id as the idempotency key',
      () async {
    final api = FakeApi()
      ..on('POST', '/api/v1/client/medications', FakeReply.ok({'id': 'srv-1'}));
    final db = testDb();
    addTearDown(db.close);
    final source = MedicationRemoteMutationSource(
        MedicationRemoteDataSource(apiClient: api.client), db);

    final id = await source.syncMutation(
      entityId: 'local-uuid-1',
      action: 'createMedication',
      payloadJson: jsonEncode({'name': 'Amlodipine', 'dosage': '5mg'}),
      createdAt: clock.now(),
    );

    expect(id, 'srv-1');
    expect(
        api
            .sent('POST', '/api/v1/client/medications')
            .single
            .headers['Idempotency-Key'],
        'local-uuid-1');
  });
}
