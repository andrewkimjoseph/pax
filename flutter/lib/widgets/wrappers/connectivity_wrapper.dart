import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/exports/shadcn.dart';
import 'package:pax/providers/connectivity/connectivity_provider.dart';

/// A widget that conditionally renders content based on internet connectivity
/// and VPN status
class ConnectivityWrapper extends ConsumerWidget {
  /// The child widget to display when connectivity conditions are met
  final Widget child;

  /// Widget to show when there's no internet connection
  final Widget? offlineWidget;

  /// Widget to show when a VPN is detected
  final Widget? vpnDetectedWidget;

  /// Whether to allow VPN connections
  final bool allowVpn;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.offlineWidget,
    this.vpnDetectedWidget,
    this.allowVpn = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);

    // Handle no internet connection
    if (!connectivityState.hasInternetConnection) {
      return offlineWidget ?? _buildDefaultOfflineWidget(context, ref);
    }

    // Handle VPN connection if not allowed
    if (!allowVpn && connectivityState.isVpnConnected) {
      return vpnDetectedWidget ?? _buildDefaultVpnWidget(context);
    }

    // All conditions met, show the child
    return child;
  }

  /// Default widget to show when offline
  Widget _buildDefaultOfflineWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.internetExplorer, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please connect to a network to use this app',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Default widget to show when VPN is detected
  Widget _buildDefaultVpnWidget(BuildContext context) {
    return Scaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(Icons.vpn_lock, size: 64),
            const SizedBox(height: 16),
            const Text(
              'VPN Connection Detected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please disconnect your VPN to use this app',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
