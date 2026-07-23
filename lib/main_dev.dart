import 'package:flutter/widgets.dart';
import 'core/config/app_config.dart';
import 'bootstrap.dart';
import 'firebase_options.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.dev");
  
  AppConfig.instance = AppConfig(
    appName: 'Yelima (Dev)',
    flavor: AppFlavor.dev,
    apiBaseUrl: dotenv.env['API_BASE_URL']!,
  );
  await bootstrap(DefaultFirebaseOptions.currentPlatform);
}
