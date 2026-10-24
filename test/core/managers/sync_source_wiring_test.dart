import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/api/api_client.dart';
import 'package:yelima/core/controllers/locale_controller.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/managers/deletion_sync_manager.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/core/services/connectivity_service.dart';
import 'package:yelima/core/services/file_service.dart';
import 'package:yelima/core/services/notification_service.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/core/services/shared_prefs_service.dart';
import 'package:yelima/features/chat/chat_injection.dart';
import 'package:yelima/features/vitals/vitals_injection.dart';
import 'package:yelima/features/medications/medications_injection.dart';
import 'package:yelima/features/symptoms/symptoms_injection.dart';
import 'package:yelima/features/user/user_injection.dart';

import '../../helpers/fake_api.dart';
import '../../helpers/fakes.dart';

class MockNotifications extends Mock implements NotificationService {}

class MockFileService extends Mock implements FileService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockPrefs extends Mock implements SharedPrefsService {}

/// Entity types the app queues for offline sync, read from the source code.
Set<String> queuedEntityTypes() => {
      for (final f
          in Directory('lib').listSync(recursive: true).whereType<File>())
        if (f.path.endsWith('.dart'))
          ...RegExp(r"entityType: '(\w+)'")
              .allMatches(f.readAsStringSync())
              .map((m) => m.group(1)!),
    };

void main() {
  final sl = GetIt.instance;
  late AppDatabase db;

  setUp(() {
    db = testDb();
    final connectivity = FakeConnectivity();
    sl
      ..registerSingleton<AppDatabase>(db)
      ..registerSingleton<APIClient>(FakeApi().client)
      ..registerSingleton<ConnectivityService>(connectivity)
      ..registerSingleton(SessionLifecycleService())
      ..registerSingleton(SessionEpoch())
      ..registerSingleton<NotificationService>(MockNotifications())
      ..registerSingleton<FileService>(MockFileService())
      ..registerSingleton<FirebaseAuth>(MockFirebaseAuth())
      ..registerSingleton<SharedPrefsService>(MockPrefs())
      ..registerSingleton(LocaleController(MockPrefs()))
      ..registerSingleton(
          MutationSyncManager(connectivityService: connectivity, db: db))
      ..registerSingleton(
          DeletionSyncManager(connectivityService: connectivity, db: db));
  });

  tearDown(() async {
    await sl.reset();
    await db.close();
  });

  test(
      'CORE-EC-04: the feature modules register a sync source for every queued type',
      () {
    initSymptoms(sl);
    initUser(sl);
    initChat(sl);
    initVitals(sl);
    initMedications(sl);

    final registered = sl<MutationSyncManager>().sourceTypes;
    expect(queuedEntityTypes().difference(registered), isEmpty);
    expect(queuedEntityTypes(), isNotEmpty);
  });
}
