import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_client.dart';
import 'config/app_config.dart';
import 'db/app_database.dart';
import 'db/daos/ai_chat_dao.dart';
import 'db/daos/medications_dao.dart';
import 'db/daos/vitals_dao.dart';
import 'managers/audio_player_manager.dart';
import 'managers/deletion_sync_manager.dart';
import 'managers/mutation_sync_manager.dart';
import 'services/app_startup_service.dart';
import 'services/connectivity_service.dart';
import 'services/database_lifecycle_handler.dart';
import 'services/day_changes.dart';
import 'services/fcm_lifecycle_handler.dart';
import 'services/fcm_token_service.dart';
import 'services/file_service.dart';
import 'services/monitoring_service.dart';
import 'services/notification_service.dart';
import 'services/recent_fetches.dart';
import 'services/session_epoch.dart';
import 'services/session_expiry.dart';
import 'services/session_lifecycle_service.dart';
import 'services/shared_prefs_service.dart';
import 'services/voice_recording_service.dart';

export 'controllers/locale_controller.dart' show localeControllerProvider;

part 'core_providers.g.dart';

/// The loaded SharedPreferences; bootstrap overrides this with the real instance.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('Overridden in bootstrap');

/// Typed access to saved settings.
@Riverpod(keepAlive: true)
SharedPrefsService sharedPrefsService(Ref ref) =>
    SharedPrefsService(ref.watch(sharedPreferencesProvider));

/// Firebase sign-in.
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

/// Firebase push messages.
@Riverpod(keepAlive: true)
FirebaseMessaging firebaseMessaging(Ref ref) => FirebaseMessaging.instance;

/// Runs session start and end steps in priority order.
@Riverpod(keepAlive: true)
SessionLifecycleService sessionLifecycle(Ref ref) => SessionLifecycleService();

/// Whether the server said the session expired.
@Riverpod(keepAlive: true)
SessionExpiry sessionExpiry(Ref ref) => SessionExpiry()
  ..also((e) => ref.watch(sessionLifecycleProvider).register(e, priority: 1));

/// Counts sessions; highest priority, so late results are dropped before the wipe.
@Riverpod(keepAlive: true)
SessionEpoch sessionEpoch(Ref ref) => SessionEpoch()
  ..also((e) => ref.watch(sessionLifecycleProvider).register(e, priority: 100));

/// The API client.
@Riverpod(keepAlive: true)
APIClient apiClient(Ref ref) => APIClient(
    baseUrl: AppConfig.instance.apiBaseUrl,
    sessionExpiry: ref.watch(sessionExpiryProvider),
    connectivity: ref.watch(connectivityProvider));

/// The encrypted local database.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();

/// Saved vital readings.
@Riverpod(keepAlive: true)
VitalsDao vitalsDao(Ref ref) => ref.watch(appDatabaseProvider).vitalsDao;

/// Saved AI chat messages.
@Riverpod(keepAlive: true)
AiChatDao aiChatDao(Ref ref) => ref.watch(appDatabaseProvider).aiChatDao;

/// Saved medications.
@Riverpod(keepAlive: true)
MedicationsDao medicationsDao(Ref ref) =>
    ref.watch(appDatabaseProvider).medicationsDao;

/// Online/offline state.
@Riverpod(keepAlive: true)
ConnectivityService connectivity(Ref ref) => ConnectivityService();

/// Whether the phone is online, for screens that change when it isn't.
@Riverpod(keepAlive: true)
Stream<bool> online(Ref ref) =>
    ref.watch(connectivityProvider).onConnectivityChanged;

/// Local file access.
@Riverpod(keepAlive: true)
FileService fileService(Ref ref) => FileServiceImpl();

/// Startup progress for the splash screen and router.
@Riverpod(keepAlive: true)
AppStartupService appStartup(Ref ref) => AppStartupService();

/// Local notifications and reminders.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) =>
    NotificationService.instance;

/// Registers this phone's push token with the server.
@Riverpod(keepAlive: true)
FCMTokenService fcmTokenService(Ref ref) =>
    FCMTokenService(ref.watch(apiClientProvider));

/// Wipes the local database on logout.
@Riverpod(keepAlive: true)
DatabaseLifecycleHandler databaseLifecycleHandler(Ref ref) =>
    DatabaseLifecycleHandler(ref.watch(appDatabaseProvider),
        onDiscarded: (n) =>
            MonitoringService.instance.logDiscardedChanges(n, reason: 'logout'))
      ..also(
          (h) => ref.watch(sessionLifecycleProvider).register(h, priority: 10));

/// Registers and removes the push token with the session.
@Riverpod(keepAlive: true)
FCMLifecycleHandler fcmLifecycleHandler(Ref ref) => FCMLifecycleHandler(
      connectivity: ref.watch(connectivityProvider),
      tokenService: () => ref.read(fcmTokenServiceProvider),
      notifications: ref.watch(notificationServiceProvider),
      messaging: ref.watch(firebaseMessagingProvider),
    )..also(
        (h) => ref.watch(sessionLifecycleProvider).register(h, priority: 60));

/// Plays chat audio.
@Riverpod(keepAlive: true)
AudioPlayerManager audioPlayerManager(Ref ref) => AudioPlayerManager();

/// Records voice notes.
@Riverpod(keepAlive: true)
VoiceRecordingService voiceRecordingService(Ref ref) => VoiceRecordingService();

/// Sends queued deletions; features add their sources.
@Riverpod(keepAlive: true)
DeletionSyncManager deletionSyncManager(Ref ref) => DeletionSyncManager(
      connectivityService: ref.watch(connectivityProvider),
      db: ref.watch(appDatabaseProvider),
    )
      ..init()
      ..also(
          (s) => ref.watch(sessionLifecycleProvider).register(s, priority: 80));

/// Sends queued changes in order; features add their sources.
@Riverpod(keepAlive: true)
MutationSyncManager mutationSyncManager(Ref ref) => MutationSyncManager(
      connectivityService: ref.watch(connectivityProvider),
      db: ref.watch(appDatabaseProvider),
    )
      ..onDiscarded = ((n) => MonitoringService.instance
          .logDiscardedChanges(n, reason: 'other_user'))
      ..init()
      ..also(
          (s) => ref.watch(sessionLifecycleProvider).register(s, priority: 80));

/// Tells screens when the date changes.
@Riverpod(keepAlive: true)
DayChanges dayChanges(Ref ref) {
  final days = DayChanges();
  ref.onDispose(days.dispose);
  return days;
}

/// Remembers recent server fetches, so screens don't refetch every visit.
@Riverpod(keepAlive: true)
RecentFetches recentFetches(Ref ref) => RecentFetches(
      connectivity: ref.watch(connectivityProvider).onConnectivityChanged,
      synced: ref.watch(mutationSyncManagerProvider).onMutationSynced,
    )..also(
        (r) => ref.watch(sessionLifecycleProvider).register(r, priority: 90));

/// Creates the core services that must exist before the first session.
void setUpCore(ProviderContainer c) {
  c
      .read(sessionLifecycleProvider)
      .register(MonitoringService.instance, priority: 5);
  c
    ..read(sessionEpochProvider)
    ..read(sessionExpiryProvider)
    ..read(databaseLifecycleHandlerProvider)
    ..read(fcmLifecycleHandlerProvider);
}

extension Also<T> on T {
  /// Runs [action] on this value and returns it, for wiring in a provider body.
  T also(void Function(T) action) {
    action(this);
    return this;
  }
}
