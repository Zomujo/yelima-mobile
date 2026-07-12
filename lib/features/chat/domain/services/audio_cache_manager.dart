import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioCacheManager {
  static final AudioCacheManager _instance = AudioCacheManager._internal();
  
  factory AudioCacheManager() {
    return _instance;
  }
  
  AudioCacheManager._internal();

  Future<void> savePath(String messageId, String absolutePath) async {
    final prefs = await SharedPreferences.getInstance();
    final filename = absolutePath.split('/').last; // Only store filename
    await prefs.setString('audio_cache_$messageId', filename);
  }

  Future<String?> getPath(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    final filename = prefs.getString('audio_cache_$messageId');

    if (filename != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fullPath = '${directory.path}/$filename';
      
      final file = File(fullPath);
      if (await file.exists()) {
        return fullPath;
      } else {
        await prefs.remove('audio_cache_$messageId');
        return null;
      }
    }
    return null;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('audio_cache_')).toList();
    
    if (keys.isEmpty) return;
    
    final directory = await getApplicationDocumentsDirectory();
    
    for (final key in keys) {
      final filename = prefs.getString(key);
      if (filename != null) {
        try {
          final file = File('${directory.path}/$filename');
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          // Ignore deletion errors for individual files
        }
      }
      await prefs.remove(key);
    }
  }
}
