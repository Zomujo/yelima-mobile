import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  /// Safely deletes a local audio file associated with a chat message.
  static Future<void> deleteLocalAudioFile(String? audioUrl) async {
    if (audioUrl == null || audioUrl.startsWith('http')) return;

    try {
      String path = audioUrl;
      if (!path.startsWith('/')) {
        final directory = await getApplicationDocumentsDirectory();
        path = '${directory.path}/$path';
      }
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Silently ignore file deletion errors to prevent crashing the sync or signout flow
    }
  }
}
