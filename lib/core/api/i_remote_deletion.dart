abstract class IRemoteDeletionSource {
  Future<void> deleteMessage(String messageId);
}
