import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  final InternetConnection _internetConnection = InternetConnection();

  Future<bool> get isConnected => _internetConnection.hasInternetAccess;

  Stream<bool> get onConnectivityChanged =>
      _internetConnection.onStatusChange.map((status) => status == InternetStatus.connected);
}
