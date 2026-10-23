import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/user/data/datasources/user_remote_data_source.dart';
import 'package:yelima/features/user/data/datasources/user_remote_mutation_source.dart';

class MockUserRemote extends Mock implements UserRemoteDataSource {}

void main() {
  late MockUserRemote remote;
  late UserRemoteMutationSource source;

  setUp(() {
    remote = MockUserRemote();
    source = UserRemoteMutationSource(remote);
    when(() => remote.updateUserProfile(any(), any())).thenAnswer((_) async {});
  });

  Future<String?> sync(String action, Map<String, dynamic> payload) =>
      source.syncMutation(
        entityId: 'uid-1',
        action: action,
        payloadJson: jsonEncode(payload),
        createdAt: DateTime(2026, 10, 23),
      );

  test('CORE-EC-04: replays a queued profile edit to the user\'s document',
      () async {
    final result = await sync('updateUserProfile',
        {'firstName': 'Ama', 'dateOfBirth': '1980-04-02T00:00:00.000'});

    verify(() => remote.updateUserProfile('uid-1', {
          'firstName': 'Ama',
          'dateOfBirth': '1980-04-02T00:00:00.000'
        })).called(1);
    expect(result, isNull, reason: 'the uid never changes, so no id remap');
  });

  test('a server failure propagates so the queue keeps the edit', () async {
    when(() => remote.updateUserProfile(any(), any()))
        .thenThrow(Exception('offline'));

    expect(
        () => sync('updateUserProfile', {'firstName': 'Ama'}), throwsException);
  });

  test('an unknown action is rejected', () {
    expect(() => sync('deleteUser', {}), throwsUnimplementedError);
  });
}
