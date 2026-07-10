import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'config/app_config.dart';
import 'network/network_info.dart';
import 'api/api_client.dart';
import 'db/app_database.dart';

import 'services/connectivity_service.dart';
import 'services/session_lifecycle_service.dart';
import 'services/sync_service.dart';
import 'services/app_startup_service.dart';
import 'services/audio_player_manager.dart';
import 'services/voice_recording_service.dart';
import 'services/notification_service.dart';
import 'services/fcm_token_service.dart';
import 'services/database_lifecycle_handler.dart';
import 'services/fcm_lifecycle_handler.dart';
import 'services/deletion_sync_manager.dart';
import 'services/mutation_sync_manager.dart';
import '../features/chat/data/datasources/ai_chat_remote_datasource.dart';

void initCore(GetIt sl) {
  // --- Core Infrastructure ---
  sl.registerLazySingleton(() => InternetConnection());
  sl.registerLazySingleton<INetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(
      () => APIClient(baseUrl: AppConfig.instance.apiBaseUrl));
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => sl<AppDatabase>().vitalsDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().aiChatDao);

  // --- Services ---
  sl.registerLazySingleton(() => ConnectivityService());
  sl.registerLazySingleton(() => SessionLifecycleService());
  sl.registerLazySingleton(() => SyncService(sl(), sl(), sl(), sl())
    ..also((s) => sl<SessionLifecycleService>().register(s, priority: 80)));

  sl.registerLazySingleton(() => AppStartupService(sl()));
  sl.registerLazySingleton(() => NotificationService.instance);
  sl.registerLazySingleton(() => FCMTokenService(sl()));

  // Register Lifecycle Handlers with SessionLifecycleService
  sl.registerLazySingleton(() => DatabaseLifecycleHandler(sl())
    ..also((h) => sl<SessionLifecycleService>().register(h, priority: 10)));

  sl.registerLazySingleton(() => FCMLifecycleHandler()
    ..also((h) => sl<SessionLifecycleService>().register(h, priority: 60)));

  // Force instantiation so they register themselves
  sl<DatabaseLifecycleHandler>();
  sl<FCMLifecycleHandler>();

  // Audio Services
  sl.registerLazySingleton(() => AudioPlayerManager());
  sl.registerLazySingleton(() => VoiceRecordingService());

  // Sync Managers
  sl.registerLazySingleton(() => DeletionSyncManager(
        connectivityService: sl(),
        db: sl(),
        remoteSources: {
          'chat': sl<AiChatRemoteDataSource>(),
        },
      )
        ..init()
        ..also((s) => sl<SessionLifecycleService>().register(s, priority: 80)));

  sl.registerLazySingleton(() => MutationSyncManager(
        connectivityService: sl(),
        db: sl(),
        remoteSources: {
          // Add sources as they are migrated to the offline-first pattern
        },
      )
        ..init()
        ..also((s) => sl<SessionLifecycleService>().register(s, priority: 80)));
}

extension _Also<T> on T {
  T also(void Function(T) action) {
    action(this);
    return this;
  }
}
