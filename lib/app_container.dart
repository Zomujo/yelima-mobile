import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/core_providers.dart';
import 'features/chat/chat_providers.dart';
import 'features/medications/medications_providers.dart';
import 'features/symptoms/symptoms_providers.dart';
import 'features/user/user_providers.dart';
import 'features/vitals/vitals_providers.dart';

/// Builds the app's providers and creates what must exist before the first session.
Future<ProviderContainer> createAppContainer() async {
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);

  setUpCore(c);
  setUpSymptoms(c);
  setUpUser(c);
  setUpChat(c);
  setUpMedications(c);
  setUpVitals(c);

  // Created now, so they are registered before the first session starts.
  c
    ..read(mutationSyncManagerProvider)
    ..read(deletionSyncManagerProvider);
  return c;
}
