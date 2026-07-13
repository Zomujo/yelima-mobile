import 'package:get_it/get_it.dart';
import 'data/datasources/ai_chat_local_datasource.dart';
import 'data/datasources/ai_chat_remote_datasource.dart';
import 'data/repositories/ai_chat_repository_impl.dart';
import 'domain/repositories/ai_chat_repository.dart';
import 'presentation/controllers/ai_chat_controller.dart';
import '../../core/services/session_lifecycle_service.dart';

void initChat(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<AiChatLocalDataSource>(
      () => AiChatLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AiChatRemoteDataSource>(
      () => AiChatRemoteDataSourceImpl(sl()));

  // Repository
  sl.registerLazySingleton<AiChatRepository>(() => AiChatRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        deletionSyncManager: sl(),
        connectivityService: sl(),
        db: sl(),
      )..also((r) => sl<SessionLifecycleService>().register(r, priority: 70)));

  // Controller
  sl.registerFactory(() => AiChatController(
        sl(),
        sl(),
      ));
}

extension _Also<T> on T {
  T also(void Function(T) action) {
    action(this);
    return this;
  }
}
