import 'package:yelima/core/utils/file_helper.dart';

abstract class FileService {
  Future<void> deleteLocalAudioFile(String? url);
}

class FileServiceImpl implements FileService {
  @override
  Future<void> deleteLocalAudioFile(String? url) async {
    await FileHelper.deleteLocalAudioFile(url);
  }
}
