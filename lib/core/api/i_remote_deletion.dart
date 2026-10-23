/// Sends one feature's queued deletions to the server.
abstract class IRemoteDeletionSource {
  Future<void> deleteMessage(String messageId);
}
