import 'package:get_it/get_it.dart';
import 'data/datasources/ai_chat_local_datasource.dart';
import 'data/datasources/ai_chat_remote_datasource.dart';
import 'data/repositories/ai_chat_repository_impl.dart';
import 'domain/repositories/ai_chat_repository.dart';
import 'presentation/controllers/ai_chat_controller.dart';
import '../../core/services/session_lifecycle_service.dart';
import '../../core/managers/mutation_sync_manager.dart';
import '../../core/managers/deletion_sync_manager.dart';
import 'data/datasources/ai_chat_remote_mutation_source.dart';

void initChat(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<AiChatLocalDataSource>(
      () => AiChatLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AiChatRemoteDataSource>(
      () => AiChatRemoteDataSourceImpl(sl()));
  sl<DeletionSyncManager>()
      .registerSource('chat', sl<AiChatRemoteDataSource>());

  // Repository
  sl.registerLazySingleton<AiChatRepository>(() => AiChatRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        deletionSyncManager: sl(),
        connectivityService: sl(),
        mutationSyncManager: sl(),
        fileService: sl(),
        session: sl(),
      )..also((r) => sl<SessionLifecycleService>().register(r, priority: 70)));

  // Controller
  sl.registerFactory(() => AiChatController(
        sl(),
        sl(),
        sl(),
      ));

  // Registered last: the source needs this feature's datasources above.
  sl<MutationSyncManager>()
      .registerSource('chat', AiChatRemoteMutationSource(sl(), sl()));
}

extension _Also<T> on T {
  T also(void Function(T) action) {
    action(this);
    return this;
  }
}
