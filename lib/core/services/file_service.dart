import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Deletes local voice-note files.
abstract class FileService {
  /// Deletes a recorded voice note; links and missing files are ignored.
  Future<void> deleteLocalAudioFile(String? url);
}

/// [FileService] on the device file system.
class FileServiceImpl implements FileService {
  @override
  Future<void> deleteLocalAudioFile(String? url) async {
    if (url == null || url.startsWith('http')) return;
    try {
      final path = url.startsWith('/')
          ? url
          : '${(await getApplicationDocumentsDirectory()).path}/$url';
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A file that can't be deleted must not break sync or sign-out.
    }
  }
}
