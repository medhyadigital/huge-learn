import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network info to check connectivity
class NetworkInfo {
  final Connectivity _connectivity;
  
  NetworkInfo(this._connectivity);
  
  /// Check if device is connected to internet
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  
  /// Get connectivity status
  Future<List<ConnectivityResult>> get connectivityStatus async {
    return await _connectivity.checkConnectivity();
  }
  
  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}

