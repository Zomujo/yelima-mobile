import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/db/app_database.dart';

class AudioCacheManager {
  static final AudioCacheManager _instance = AudioCacheManager._internal();

  factory AudioCacheManager() {
    return _instance;
  }

  AudioCacheManager._internal();

  Future<void> savePath(String messageId, String absolutePath) async {
    final filename = absolutePath.split('/').last; // Only store filename
    await GetIt.instance<AppDatabase>()
        .audioCacheDao
        .savePath(messageId, filename);
  }

  Future<String?> getPath(String messageId) async {
    final filename =
        await GetIt.instance<AppDatabase>().audioCacheDao.getPath(messageId);

    if (filename != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fullPath = '${directory.path}/$filename';

      final file = File(fullPath);
      if (await file.exists()) {
        return fullPath;
      } else {
        await GetIt.instance<AppDatabase>().audioCacheDao.removePath(messageId);
        return null;
      }
    }
    return null;
  }

  Future<void> clearCache() async {
    final filenames =
        await GetIt.instance<AppDatabase>().audioCacheDao.getAllFilenames();

    if (filenames.isEmpty) return;

    final directory = await getApplicationDocumentsDirectory();

    for (final filename in filenames) {
      try {
        final file = File('${directory.path}/$filename');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Ignore deletion errors for individual files
      }
    }

    await GetIt.instance<AppDatabase>().audioCacheDao.clearCache();
  }
}
