import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every tutorial step points at a widget that exists on some screen', () {
    final service = File(
            'lib/features/onboarding/presentation/tutorials/app_tutorial_service.dart')
        .readAsStringSync();
    final used = RegExp(r'AppTutorialKeys\.(\w+)')
        .allMatches(service)
        .map((m) => m[1]!)
        .toSet();
    final screens = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) =>
            f.path.endsWith('.dart') &&
            !f.path.contains('app_tutorial_service'))
        .map((f) => f.readAsStringSync())
        .join('\n');

    final missing = [
      for (final key in used)
        if (!screens.contains('key: AppTutorialKeys.$key')) key
    ];
    expect(missing, isEmpty);
  });
}
