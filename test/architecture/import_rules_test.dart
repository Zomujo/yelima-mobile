import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Every lib file with the lib-relative paths it imports (generated files skipped).
Map<String, List<String>> importsByFile() {
  final result = <String, List<String>>{};
  final import = RegExp(r"^(?:import|export) '([^']+)'", multiLine: true);
  for (final f
      in Directory('lib').listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart') ||
        RegExp(r'\.(g|freezed)\.dart$').hasMatch(f.path)) {
      continue;
    }
    result[f.path] = [
      for (final m in import.allMatches(f.readAsStringSync()))
        if (m[1]!.startsWith('package:yelima/'))
          'lib/${m[1]!.substring('package:yelima/'.length)}'
        else if (!m[1]!.contains(':'))
          p.normalize(p.join(p.dirname(f.path), m[1]!)),
    ];
  }
  return result;
}

void main() {
  final imports = importsByFile();

  List<String> violations(bool Function(String file, String target) rule) => [
        for (final e in imports.entries)
          for (final t in e.value)
            if (rule(e.key, t)) '${e.key} -> $t',
      ];

  test(
      'core and shared never import feature code (the router composes screens)',
      () {
    expect(
      violations((file, target) =>
          (file.startsWith('lib/core/') || file.startsWith('lib/shared/')) &&
          file != 'lib/core/router/router.dart' &&
          target.startsWith('lib/features/')),
      isEmpty,
    );
  });

  test('domain code never imports data or presentation code', () {
    expect(
      violations((file, target) =>
          file.contains('/domain/') &&
          (target.contains('/data/') || target.contains('/presentation/'))),
      isEmpty,
    );
  });

  test('data code never imports presentation code', () {
    expect(
      violations((file, target) =>
          file.contains('/data/') && target.contains('/presentation/')),
      isEmpty,
    );
  });

  test('domain and presentation never touch Firebase, HTTP or the database',
      () {
    final infra = RegExp(
        r"^import 'package:(firebase_\w+|cloud_firestore|dio|drift|sqlite3|google_sign_in|sign_in_with_apple|flutter_secure_storage|shared_preferences)/",
        multiLine: true);
    final appDb = RegExp(r"^import '[^']*core/db/", multiLine: true);
    // Features not cleaned up yet; remove each one as it's done.
    const pending = {'chat', 'home', 'profile', 'user'};
    final bad = <String>[];
    for (final f in Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()) {
      final path = f.path;
      if (!path.endsWith('.dart') ||
          RegExp(r'\.(g|freezed)\.dart$').hasMatch(path) ||
          !(path.contains('/domain/') || path.contains('/presentation/')) ||
          pending.contains(path.split('/')[2])) {
        continue;
      }
      final src = f.readAsStringSync();
      if (infra.hasMatch(src) || appDb.hasMatch(src)) bad.add(path);
    }
    expect(bad, isEmpty);
  });

  test('relative imports never climb above lib/', () {
    final bad = <String>[];
    final import = RegExp(r"^(?:import|export) '([^':]+)'", multiLine: true);
    for (final f
        in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      for (final m in import.allMatches(f.readAsStringSync())) {
        final target = p.normalize(p.join(p.dirname(f.path), m[1]!));
        if (!p.isWithin('lib', target)) bad.add('${f.path} -> ${m[1]}');
      }
    }
    expect(bad, isEmpty);
  });
}
