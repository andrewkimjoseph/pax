import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service to check internet connectivity and VPN status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  /// Stream that broadcasts connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  ConnectivityService() {
    // Initialize connectivity monitoring
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      } else {
        _updateConnectionStatus(ConnectivityResult.none);
      }
    });
  }

  /// Initialize the service and get initial status
  Future<ConnectivityStatus> initialize() async {
    return await checkConnectivity();
  }

  /// Update connection status when connectivity changes
  void _updateConnectionStatus(ConnectivityResult result) async {
    final status = await _determineStatus(result);
    _statusController.add(status);
  }

  /// Check current connectivity status
  Future<ConnectivityStatus> checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return await _determineStatus(connectivityResult.first);
  }

  /// Determine the status based on connectivity result
  Future<ConnectivityStatus> _determineStatus(ConnectivityResult result) async {
    // First check if there's any connectivity
    if (result == ConnectivityResult.none) {
      return ConnectivityStatus.offline;
    }

    // Check if we can actually reach the internet
    final hasInternet = await _checkInternetAccess();
    if (!hasInternet) {
      return ConnectivityStatus.offline;
    }

    // Check if VPN is connected
    final isVpnConnected = await _isVpnConnected();
    if (isVpnConnected) {
      return ConnectivityStatus.vpnConnected;
    }

    return ConnectivityStatus.online;
  }

  /// Check if device can actually reach the internet
  Future<bool> _checkInternetAccess() async {
    try {
      // Try to reach multiple endpoints to confirm internet connectivity
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      debugPrint('Error checking internet access: $e');
      return false;
    }
  }

  /// Check if a VPN is currently connected
  Future<bool> _isVpnConnected() async {
    if (Platform.isAndroid) {
      return _checkAndroidVpn();
    } else if (Platform.isIOS) {
      return _checkIosVpn();
    }
    // For other platforms, assume no VPN
    return false;
  }

  /// Check for VPN on Android
  Future<bool> _checkAndroidVpn() async {
    try {
      // Check for VPN interfaces such as tun0, ppp0
      final result = await Process.run('ifconfig', []);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        return output.contains('tun0') ||
            output.contains('ppp0') ||
            output.contains('vpn');
      }

      // Alternative: Check for VPN network interfaces
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        if (interface.name.contains('tun') ||
            interface.name.contains('ppp') ||
            interface.name.contains('vpn')) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking Android VPN: $e');
      return false; // Assume no VPN if there's an error
    }
  }

  /// Check for VPN on iOS
  Future<bool> _checkIosVpn() async {
    try {
      // On iOS, check network interfaces
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        // VPN interfaces on iOS typically use ipsec or utun
        if (interface.name.contains('ipsec') ||
            interface.name.contains('utun') ||
            interface.name.contains('vpn')) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking iOS VPN: $e');
      return false; // Assume no VPN if there's an error
    }
  }

  /// Dispose resources
  void dispose() {
    _statusController.close();
  }
}

/// Represents the current connectivity status
enum ConnectivityStatus { online, offline, vpnConnected }
