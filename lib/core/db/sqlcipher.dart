// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

/// Points sqlite3 at SQLCipher on Android. Call it on every isolate that opens the database.
void useSqlCipher() {
  if (Platform.isAndroid) {
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
  }
}

/// Opens the database with [key]. Throws if [db] isn't SQLCipher, where the key would do nothing.
void unlock(Database db, String key) {
  if (db.select('PRAGMA cipher_version;').isEmpty) {
    throw StateError('SQLCipher is not available; refusing to open the database.');
  }
  db.execute("PRAGMA key = '$key';");
}

/// Whether [key] opens [file]. A missing SQLCipher throws instead, so data is never moved aside for it.
bool opensWith(File file, String key) {
  final db = sqlite3.open(file.path);
  try {
    unlock(db, key);
    try {
      db.execute('SELECT count(*) FROM sqlite_master;');
      return true;
    } on SqliteException catch (e) {
      debugPrint('Database decryption failed or file corrupted: $e');
      return false;
    }
  } finally {
    db.dispose();
  }
}
