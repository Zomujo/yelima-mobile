import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/i_remote_deletion.dart';

/// The AI chat endpoints of the API.
class AiChatRemoteDataSource implements IRemoteDeletionSource {
  AiChatRemoteDataSource(this._api, {required String Function() languageCode})
      : _languageCode = languageCode;

  final APIClient _api;
  final String Function() _languageCode;

  /// The AI only speaks English and Twi; every other app language gets English.
  static String chatLanguage(String languageCode) =>
      languageCode == 'tw' ? 'Twi' : 'English';

  String get _lang => chatLanguage(_languageCode());

  /// The server's largest history page.
  static const maxPageSize = 100;

  /// One page of history: `{rows, totalPages}`.
  Future<Map<String, dynamic>> fetchChats(
      {required int page, int limit = 20}) async {
    final response = await _api.get('/api/v1/client/chats',
        queryParameters: {'page': page, 'limit': limit.clamp(1, maxPageSize)});
    return response is Map ? (response['data'] ?? response) : {};
  }

  /// The bot's greeting, or null.
  Future<Map<String, dynamic>?> getInitialMessage() async =>
      _data(await _api.post('/api/v1/client/chat',
          queryParameters: {'lang': _lang},
          data: {'message': ''}))?['outResponse'];

  /// Sends text; returns `{inResponse, outResponse}`, or `{}` when the server sent no reply.
  Future<Map<String, dynamic>> sendMessage(String message,
          {String? localChatId}) async =>
      _reply(await _api.post('/api/v1/client/chat', queryParameters: {
        'lang': _lang
      }, data: {
        'message': message,
        if (localChatId != null) 'localChatId': localChatId,
      }));

  /// Sends a voice note; same result as [sendMessage].
  Future<Map<String, dynamic>> sendAudioMessage(
          {required String filePath, String? localChatId}) async =>
      _reply(await _api.postMultipart(
        '/api/v1/client/chat/audio',
        files: {
          'file': await MultipartFile.fromFile(filePath,
              filename: filePath.split('/').last)
        },
        queryParameters: {
          'lang': _lang,
          if (localChatId != null) 'audioId': localChatId,
        },
      ));

  @override
  Future<void> deleteMessage(String id) =>
      _api.delete('/api/v1/client/chats/$id');

  static Map<String, dynamic>? _data(dynamic response) =>
      response is Map ? response['data'] as Map<String, dynamic>? : null;

  static Map<String, dynamic> _reply(dynamic response) {
    final data = _data(response);
    return data?['outResponse'] == null ? {} : data!;
  }
}
