import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import 'config/app_config.dart';

import 'api/api_client.dart';
import 'db/app_database.dart';

import 'services/connectivity_service.dart';
import 'services/session_lifecycle_service.dart';
import 'services/app_startup_service.dart';
import 'services/file_service.dart';
import 'controllers/locale_controller.dart';
import 'managers/audio_player_manager.dart';
import 'services/voice_recording_service.dart';
import 'services/notification_service.dart';
import 'services/monitoring_service.dart';
import 'services/recent_fetches.dart';
import 'services/session_epoch.dart';
import 'services/session_expiry.dart';
import 'services/fcm_token_service.dart';
import 'services/database_lifecycle_handler.dart';
import 'services/fcm_lifecycle_handler.dart';
import 'managers/deletion_sync_manager.dart';
import 'managers/mutation_sync_manager.dart';

void initCore(GetIt sl) {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => SessionExpiry());
  sl.registerLazySingleton(() =>
      APIClient(baseUrl: AppConfig.instance.apiBaseUrl, sessionExpiry: sl()));
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => sl<AppDatabase>().vitalsDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().aiChatDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().medicationsDao);

  sl.registerLazySingleton(() => ConnectivityService());
  sl.registerLazySingleton(() => SessionLifecycleService());
  sl.registerLazySingleton<FileService>(() => FileServiceImpl());

  sl.registerLazySingleton(() => AppStartupService());
  sl.registerLazySingleton(() => NotificationService.instance);
  sl.registerLazySingleton(() => FCMTokenService(sl(), sl()));
  sl.registerLazySingleton(() => LocaleController(sl()));

  // Register Lifecycle Handlers with SessionLifecycleService
  sl.registerLazySingleton(() => DatabaseLifecycleHandler(sl(),
      onDiscarded: (n) =>
          MonitoringService.instance.logDiscardedChanges(n, reason: 'logout'))
    ..also((h) => sl<SessionLifecycleService>().register(h, priority: 10)));

  sl<SessionLifecycleService>()
      .register(MonitoringService.instance, priority: 5);
  // Highest priority, so it runs first on session end and late results are dropped before the wipe.
  sl.registerSingleton(SessionEpoch());
  sl<SessionLifecycleService>().register(sl<SessionEpoch>(), priority: 100);
  sl<SessionLifecycleService>().register(sl<SessionExpiry>(), priority: 1);

  sl.registerLazySingleton(() => FCMLifecycleHandler(
        connectivity: sl(),
        tokenService: () => sl(),
        notifications: sl(),
        messaging: sl(),
      )..also((h) => sl<SessionLifecycleService>().register(h, priority: 60)));

  // Force instantiation so they register themselves
  sl<DatabaseLifecycleHandler>();
  sl<FCMLifecycleHandler>();

  // Audio Services
  sl.registerLazySingleton(() => AudioPlayerManager());
  sl.registerLazySingleton(() => VoiceRecordingService());

  // Sync Managers
  // Features register their sources with registerSource in their own injection.
  sl.registerLazySingleton(() => DeletionSyncManager(
        connectivityService: sl(),
        db: sl(),
      )
        ..init()
        ..also((s) => sl<SessionLifecycleService>().register(s, priority: 80)));

  sl.registerLazySingleton(() => MutationSyncManager(
        connectivityService: sl(),
        db: sl(),
      )
        ..onDiscarded = ((n) => MonitoringService.instance
            .logDiscardedChanges(n, reason: 'other_user'))
        ..init()
        ..also((s) => sl<SessionLifecycleService>().register(s, priority: 80)));

  sl.registerLazySingleton(() => RecentFetches(
        connectivity: sl<ConnectivityService>().onConnectivityChanged,
        synced: sl<MutationSyncManager>().onMutationSynced,
      )..also((r) => sl<SessionLifecycleService>().register(r, priority: 90)));
}

extension _Also<T> on T {
  T also(void Function(T) action) {
    action(this);
    return this;
  }
}
