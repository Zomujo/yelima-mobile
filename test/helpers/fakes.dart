import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/connectivity_service.dart';

/// Fresh app database held in memory (no SQLCipher), one per test.
AppDatabase testDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(executor: NativeDatabase.memory());
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
  Future<bool> get hasNetworkInterface async => online;

  @override
  Stream<bool> get onConnectivityChanged => _changes.stream;

  @override
  Stream<bool> get onNetworkInterfaceChanged => _changes.stream;
}
