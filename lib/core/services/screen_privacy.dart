import 'package:screen_protector/screen_protector.dart';

import '../utils/logger.dart';

/// Blanks screenshots and screen recordings, and blurs the app in the app switcher.
Future<void> protectScreens() async {
  try {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageWithBlur();
  } catch (e, stack) {
    AppLogger.e('Screen protection failed', e, stack);
  }
}
