import 'package:get_it/get_it.dart';

import 'presentation/controllers/home_metrics_controller.dart';

/// Registers the home feature; its data comes from vitals and medications.
void initHome(GetIt sl) {
  sl.registerFactory<HomeMetricsController>(
      () => HomeMetricsController(vitals: sl(), medications: sl()));
}
