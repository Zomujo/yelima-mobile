abstract class WebSocketClient {
  Stream<dynamic> get stream;
  bool get isConnected;
  void connect(String url);
  void send(dynamic data);
  void disconnect();
}
