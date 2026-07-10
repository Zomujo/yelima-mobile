import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class INetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements INetworkInfo {
  final InternetConnection _internetConnection;

  NetworkInfoImpl(this._internetConnection);

  @override
  Future<bool> get isConnected => _internetConnection.hasInternetAccess;

  @override
  Stream<bool> get onConnectivityChanged =>
      _internetConnection.onStatusChange.map((status) => status == InternetStatus.connected);
}
