import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetConnection = InternetConnection.createInstance(
    checkInterval: const Duration(seconds: 10),
  );

  // Fast OS-level checks (for UI responsiveness)
  Future<bool> get hasNetworkInterface async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Stream<bool> get onNetworkInterfaceChanged => _connectivity.onConnectivityChanged
      .map((result) => !result.contains(ConnectivityResult.none));

  // Robust ping checks (for background sync engines)
  Future<bool> get isConnected async {
    if (!await hasNetworkInterface) return false;
    return await _internetConnection.hasInternetAccess;
  }

  Stream<bool> get onConnectivityChanged => _internetConnection.onStatusChange
      .map((status) => status == InternetStatus.connected);
}
