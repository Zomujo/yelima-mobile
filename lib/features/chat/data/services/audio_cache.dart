import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/db/app_database.dart';

/// Downloaded voice notes on the phone, found by message id.
class AudioCache {
  AudioCache(this._db);

  final AppDatabase _db;

  Future<String> get _dir async =>
      (await getApplicationDocumentsDirectory()).path;

  /// The saved file for the first of [ids] that has one, or null.
  Future<String?> pathFor(List<String> ids) async {
    for (final id in ids) {
      final name = await _db.audioCacheDao.getPath(id);
      if (name == null) continue;
      final path = '${await _dir}/$name';
      if (await File(path).exists()) return path;
      await _db.audioCacheDao.removePath(id);
    }
    return null;
  }

  /// Downloads [url] and remembers it under each of [ids]; returns the file path.
  Future<String> download(String url, List<String> ids) async {
    final name = 'audio_${ids.first}.m4a';
    final path = '${await _dir}/$name';
    await Dio().download(url, path);
    for (final id in ids) {
      await _db.audioCacheDao.savePath(id, name);
    }
    return path;
  }

  /// Deletes every downloaded voice note.
  Future<void> clear() async {
    final dir = await _dir;
    for (final name in await _db.audioCacheDao.getAllFilenames()) {
      try {
        final file = File('$dir/$name');
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    await _db.audioCacheDao.clearCache();
  }
}
