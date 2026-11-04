import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/file_service.dart';
import 'package:yelima/core/services/notification_service.dart';
import 'package:yelima/core/core_providers.dart';
import 'package:yelima/core/services/shared_prefs_service.dart';
import 'package:yelima/features/chat/chat_providers.dart';
import 'package:yelima/features/vitals/vitals_providers.dart';
import 'package:yelima/features/medications/medications_providers.dart';
import 'package:yelima/features/symptoms/symptoms_providers.dart';
import 'package:yelima/features/user/user_providers.dart';

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
  late AppDatabase db;
  late ProviderContainer c;

  setUp(() {
    db = testDb();
    final prefs = MockPrefs();
    c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      apiClientProvider.overrideWithValue(FakeApi().client),
      connectivityProvider.overrideWithValue(FakeConnectivity()),
      notificationServiceProvider.overrideWithValue(MockNotifications()),
      fileServiceProvider.overrideWithValue(MockFileService()),
      firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
      sharedPrefsServiceProvider.overrideWithValue(prefs),
    ]);
  });

  tearDown(() async {
    c.dispose();
    await db.close();
  });

  test(
      'CORE-EC-04: the feature modules register a sync source for every queued type',
      () {
    setUpSymptoms(c);
    setUpUser(c);
    setUpChat(c);
    setUpVitals(c);
    setUpMedications(c);

    final registered = c.read(mutationSyncManagerProvider).sourceTypes;
    expect(queuedEntityTypes().difference(registered), isEmpty);
    expect(queuedEntityTypes(), isNotEmpty);
  });
}
