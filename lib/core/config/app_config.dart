enum AppFlavor { dev, staging, prod }

class AppConfig {
  final String appName;
  final AppFlavor flavor;
  final String apiBaseUrl;
  final Duration connectTimeout;

  const AppConfig({
    required this.appName,
    required this.flavor,
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 30),
  });

  static late AppConfig instance;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isProd => flavor == AppFlavor.prod;

  // Convenience: only enable verbose logging in non-prod
  bool get isDebugMode => flavor != AppFlavor.prod;
}
