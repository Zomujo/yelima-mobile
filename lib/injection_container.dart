import 'package:get_it/get_it.dart';

import 'core/core_injection.dart';
import 'features/auth/auth_injection.dart';
import 'features/user/user_injection.dart';
import 'features/chat/chat_injection.dart';
import 'features/progress/progress_injection.dart';
import 'features/profile/profile_injection.dart';
import 'features/home/home_injection.dart';
import 'features/medications/medications_injection.dart';
import 'features/appointment/appointment_injection.dart';
import 'features/reading_logging/reading_logging_injection.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Core Infrastructure & Services ---
  initCore(sl);

  // --- Features ---
  initAuth(sl);
  initUser(sl);
  initChat(sl);
  initProgress(sl);
  initProfile(sl);
  initHome(sl);
  initMedications(sl);
  initAppointment(sl);
  initReadingLogging(sl);

  // Wait for async singletons if any
  // await sl.allReady();
}
