import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/utils/logger.dart';

void main() {
  late DebugPrintCallback original;
  setUp(() => original = debugPrint);
  tearDown(() => debugPrint = original);

  test(
      'CORE-EC-12: release builds silence debugPrint so bodies never reach device logs',
      () {
    final printed = <String?>[];
    debugPrint = (m, {wrapWidth}) => printed.add(m);

    silenceDebugPrintInRelease(isRelease: true);
    debugPrint('API Raw Data: {"bloodPressure": "150/95"}');

    expect(printed, isEmpty);
  });

  test('debug builds keep debugPrint', () {
    final printed = <String?>[];
    debugPrint = (m, {wrapWidth}) => printed.add(m);

    silenceDebugPrintInRelease(isRelease: false);
    debugPrint('hello');

    expect(printed, ['hello']);
  });
}
