/// The two builds: development and production.
enum AppFlavor { dev, prod }

/// Settings that differ per flavor, set once at startup.
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.flavor,
    required this.apiBaseUrl,
  });

  final String appName;
  final AppFlavor flavor;
  final String apiBaseUrl;

  static late AppConfig instance;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;

  /// Verbose logging outside production.
  bool get isDebugMode => !isProd;
}
