import 'package:get_it/get_it.dart';

import 'domain/usecases/save_vital_reading_usecase.dart';
import 'presentation/controllers/reading_logging_controller.dart';

void initReadingLogging(GetIt sl) {
  // Use cases
  sl.registerLazySingleton<SaveVitalReadingUseCase>(
      () => SaveVitalReadingUseCase(sl()));

  // Controllers
  sl.registerFactory(() => ReadingLoggingController(
        repository: sl(),
        saveVitalReadingUseCase: sl(),
        networkInfo: sl(),
      ));
}
