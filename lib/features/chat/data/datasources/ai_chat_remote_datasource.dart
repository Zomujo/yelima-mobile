import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/i_remote_deletion.dart';

abstract class AiChatRemoteDataSource implements IRemoteDeletionSource {
  Future<Map<String, dynamic>> fetchChats({required int page, int limit = 20});
  Future<Map<String, dynamic>> sendMessage(String message,
      {String? localChatId});
  Future<Map<String, dynamic>> sendAudioMessage(
      {required String filePath, String? localChatId});
  Future<Map<String, dynamic>?> getInitialMessage();
  @override
  Future<void> deleteMessage(String id);
}

class AiChatRemoteDataSourceImpl implements AiChatRemoteDataSource {
  final APIClient _apiClient;

  AiChatRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> fetchChats(
      {required int page, int limit = 20}) async {
    final response = await _apiClient.get(
      "/api/v1/client/chats",
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    if (response == null || response == "") return {};
    return response['data'] ?? response; // Depending on API response wrapper
  }

  @override
  Future<Map<String, dynamic>?> getInitialMessage() async {
    final response = await _apiClient
        .post("/api/v1/client/chat?lang=English", data: {"message": ""});
    if (response == null || response == "") return null;

    Map<String, dynamic> responseData =
        response is Map ? response as Map<String, dynamic> : response.data;
    if (responseData['data'] == null) return null;
    return responseData['data']['outResponse'];
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String message,
      {String? localChatId}) async {
    final response =
        await _apiClient.post("/api/v1/client/chat?lang=English", data: {
      "message": message,
      if (localChatId != null) "localChatId": localChatId,
    });
    if (response == null || response == "") return {};
    return response is Map ? response as Map<String, dynamic> : response.data;
  }

  @override
  Future<Map<String, dynamic>> sendAudioMessage({
    required String filePath,
    String? localChatId,
  }) async {
    final audioFile = await MultipartFile.fromFile(
      filePath,
      filename: filePath.split('/').last,
    );

    final Map<String, MultipartFile> files = {'file': audioFile};

    final response = await _apiClient.postMultipart(
      "/api/v1/client/chat/audio",
      files: files,
      queryParameters: {
        'lang': 'English',
        if (localChatId != null) 'audioId': localChatId,
      },
    );
    if (response == null || response == "") return {};
    return response is Map ? response as Map<String, dynamic> : response.data;
  }

  @override
  Future<void> deleteMessage(String id) async {
    await _apiClient.delete("/api/v1/client/chats/$id");
  }
}
