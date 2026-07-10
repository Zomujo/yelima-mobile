import 'package:flutter/widgets.dart';
import 'core/config/app_config.dart';
import 'bootstrap.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.instance = const AppConfig(
    appName: 'yelima',
    flavor: AppFlavor.prod,
    apiBaseUrl: 'https://dnh-server-production.up.railway.app/',
  );

  await bootstrap(DefaultFirebaseOptions.currentPlatform);
}
