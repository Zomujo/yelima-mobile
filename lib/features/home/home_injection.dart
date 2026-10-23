import 'package:get_it/get_it.dart';

import 'presentation/controllers/home_metrics_controller.dart';

void initHome(GetIt sl) {
  // Controller; its data comes from the vitals feature.
  sl.registerFactory<HomeMetricsController>(
      () => HomeMetricsController(repository: sl()));
}
