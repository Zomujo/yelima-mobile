import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/services/connectivity_service.dart';

/// Fresh app database held in memory (no SQLCipher), one per test.
AppDatabase testDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(executor: NativeDatabase.memory());
}

/// Sync manager that only counts how often a sync was started.
class FakeSync extends Fake implements MutationSyncManager {
  int syncs = 0;

  @override
  Future<void> triggerSync() async => syncs++;
}

/// Connectivity you switch on and off from the test.
class FakeConnectivity implements ConnectivityService {
  FakeConnectivity({this.online = true});

  bool online;
  final _changes = StreamController<bool>.broadcast();

  /// Changes the connection and notifies listeners.
  void set(bool value) {
    online = value;
    _changes.add(value);
  }

  @override
  Future<bool> get isConnected async => online;

  @override
  bool get lastKnownOnline => online;

  @override
  Stream<bool> get onConnectivityChanged => _changes.stream;

  @override
  void sawReply() {}

  @override
  void sawNetworkError() {}

  @override
  void pause() {}

  @override
  void resume() {}
}
