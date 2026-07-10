import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('Dev flavor properties', () {
      AppConfig.instance = const AppConfig(
        appName: 'Yelima Dev',
        flavor: AppFlavor.dev,
        apiBaseUrl: 'https://dev.api.com',
      );
      expect(AppConfig.instance.isDev, isTrue);
      expect(AppConfig.instance.isProd, isFalse);
      expect(AppConfig.instance.isDebugMode, isTrue);
    });

    test('Prod flavor properties', () {
      AppConfig.instance = const AppConfig(
        appName: 'Yelima Prod',
        flavor: AppFlavor.prod,
        apiBaseUrl: 'https://prod.api.com',
      );
      expect(AppConfig.instance.isProd, isTrue);
      expect(AppConfig.instance.isDev, isFalse);
      expect(AppConfig.instance.isDebugMode, isFalse);
    });
  });
}
