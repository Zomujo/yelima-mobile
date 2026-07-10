import 'package:flutter/foundation.dart';

enum LogType { info, warning, error, success, debug }

class _AnsiColors {
  // Text colors
  static const String reset = '\x1B[0m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';

  // Bright colors
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
  static const String brightBlue = '\x1B[94m';
  static const String magenta = '\x1B[35m';

  // Text styles
  static const String bold = '\x1B[1m';
  static const String dim = '\x1B[2m';
}

class LogConfig {
  final String color;
  final String emoji;
  final String label;

  const LogConfig(this.color, this.emoji, this.label);
}

const Map<LogType, LogConfig> logConfigs = {
  LogType.success: LogConfig(_AnsiColors.brightGreen, '✅', 'SUCCESS'),
  LogType.warning: LogConfig(_AnsiColors.brightYellow, '⚠️', 'WARNING'),
  LogType.error: LogConfig(_AnsiColors.brightRed, '❌', 'ERROR'),
  LogType.info: LogConfig(_AnsiColors.brightBlue, 'ℹ️', 'INFO'),
  LogType.debug: LogConfig(_AnsiColors.magenta, '🐛', 'DEBUG'),
};

class AppLogger {
  AppLogger._();

  static void log(String? message, {LogType type = LogType.info}) {
    if (!kDebugMode) return;

    final config = logConfigs[type]!;
    final color = config.color;
    final emoji = config.emoji;
    final label = config.label;

    final divider = '═' * 70;

    final output = '''
$color${_AnsiColors.bold}╔$divider╗
║ $emoji  $label MESSAGE $emoji
╠$divider╣${_AnsiColors.reset}
$color║${_AnsiColors.reset} $message
$color╚$divider╝${_AnsiColors.reset}''';

    debugPrint(output);
  }

  static void d(String message) => log(message, type: LogType.debug);
  static void i(String message) => log(message, type: LogType.info);
  static void w(String message) => log(message, type: LogType.warning);
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    String msg = message;
    if (error != null) msg += '\nError: $error';
    if (stackTrace != null) msg += '\nStackTrace: $stackTrace';
    log(msg, type: LogType.error);
  }

  static void logMap(
    Map<String, dynamic>? data, {
    String? title,
    LogType type = LogType.warning,
  }) {
    if (!kDebugMode) return;

    final config = logConfigs[type]!;
    final color = config.color;
    final emoji = config.emoji;
    final divider = '═' * 70;

    String output = '''
$color${_AnsiColors.bold}╔$divider╗
║ $emoji  ${title ?? 'DATA LOG'} $emoji
╠$divider╣${_AnsiColors.reset}''';

    if (data != null && data.isNotEmpty) {
      for (String key in data.keys) {
        final value = data[key];
        output +=
            '\n$color║${_AnsiColors.reset} ${_AnsiColors.cyan}$key:${_AnsiColors.reset} ${_AnsiColors.white}$value${_AnsiColors.reset}';
      }
    } else {
      output +=
          '\n$color║${_AnsiColors.reset} ${_AnsiColors.dim}No data to log 🫙${_AnsiColors.reset}';
    }

    output += '\n$color╚$divider╝${_AnsiColors.reset}';

    debugPrint(output);
  }
}
