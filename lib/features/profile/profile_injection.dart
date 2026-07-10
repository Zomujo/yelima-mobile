import 'package:get_it/get_it.dart';

import 'presentation/controllers/edit_profile_controller.dart';

void initProfile(GetIt sl) {
  sl.registerFactory(
    () => EditProfileController(
      repository: sl(),
      userController: sl(),
    ),
  );
}
