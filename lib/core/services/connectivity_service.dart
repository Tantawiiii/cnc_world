import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  bool? _lastStatus;

  Stream<bool> get connectivityStream => _connectivityController.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final bool hasInternetAccess = await hasInternet();
    _emitStatus(hasInternetAccess);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) async {
    final bool hasInterface = results.any((result) => result != ConnectivityResult.none);
    
    if (!hasInterface) {
      _emitStatus(false);
    } else {
      // If interface is up, verify actual internet access
      final bool hasAccess = await _checkRealInternet();
      _emitStatus(hasAccess);
    }
  }

  void _emitStatus(bool status) {
    if (_lastStatus == status) return;
    _lastStatus = status;
    _connectivityController.add(status);
  }

  Future<bool> _checkRealInternet() async {
    final hosts = ['google.com', 'cloudflare.com', 'opendns.com'];
    
    for (var host in hosts) {
      try {
        final result = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        continue; // Try next host
      }
    }
    return false;
  }

  Future<bool> hasInternet() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    final bool hasInterface = results.any((result) => result != ConnectivityResult.none);
    
    if (!hasInterface) return false;
    return await _checkRealInternet();
  }

  /// Manually notify that connection failed (e.g. from an interceptor)
  void setDisconnected() {
    _emitStatus(false);
  }

  void dispose() {
    _connectivityController.close();
  }
}
