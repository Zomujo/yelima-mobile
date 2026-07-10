import 'package:get_it/get_it.dart';
import 'data/datasources/ai_chat_local_datasource.dart';
import 'data/datasources/ai_chat_remote_datasource.dart';
import 'data/repositories/ai_chat_repository_impl.dart';
import 'domain/repositories/ai_chat_repository.dart';
import 'presentation/controllers/ai_chat_controller.dart';

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
      ));

  // Controller
  sl.registerFactory(() => AiChatController(
        sl(),
        sl(),
      ));
}
