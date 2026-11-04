// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:yelima/core/db/sqlcipher.dart';

void main() {
  // The test host has plain sqlite3, which is exactly the case these guard against.
  group('without SQLCipher', () {
    test('unlock refuses instead of running a key pragma that does nothing', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.dispose);
      expect(() => unlock(db, 'key'), throwsStateError);
    });

    test('opensWith throws, so the database is not moved aside', () {
      final dir = Directory.systemTemp.createTempSync('sqlcipher_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/db.sqlite');
      sqlite3.open(file.path)
        ..execute('CREATE TABLE t (x INTEGER);')
        ..dispose();

      expect(() => opensWith(file, 'key'), throwsStateError);
      expect(file.existsSync(), isTrue);
    });
  });
}
