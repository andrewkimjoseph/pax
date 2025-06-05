import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/services/connectivity/connectivity_service.dart';

/// State class that holds the connectivity status
class ConnectivityState {
  final ConnectivityStatus status;

  const ConnectivityState({required this.status});

  /// Whether the device has internet connection and no VPN
  bool get isConnectedWithoutVpn => status == ConnectivityStatus.online;

  /// Whether the device has any internet connection (with or without VPN)
  bool get hasInternetConnection =>
      status == ConnectivityStatus.online ||
      status == ConnectivityStatus.vpnConnected;

  /// Whether a VPN is currently connected
  bool get isVpnConnected => status == ConnectivityStatus.vpnConnected;

  /// Creates a copy of the current state with specified parameters changed
  ConnectivityState copyWith({ConnectivityStatus? status}) {
    return ConnectivityState(status: status ?? this.status);
  }
}

/// Notifier that manages connectivity state
class ConnectivityNotifier extends Notifier<ConnectivityState> {
  late final ConnectivityService _connectivityService;
  StreamSubscription<ConnectivityStatus>? _subscription;

  @override
  ConnectivityState build() {
    _connectivityService = ref.read(connectivityServiceProvider);

    // Initialize state with offline status first
    // The actual status will be updated soon after initialization
    _initialize();

    // Set up disposal of resources when the notifier is disposed
    ref.onDispose(() {
      _subscription?.cancel();
    });

    // Initial state before connectivity check completes
    return const ConnectivityState(status: ConnectivityStatus.offline);
  }

  /// Initialize the notifier and start listening for connectivity changes
  Future<void> _initialize() async {
    // Get initial status
    final initialStatus = await _connectivityService.initialize();
    state = ConnectivityState(status: initialStatus);

    // Subscribe to status changes
    _subscription = _connectivityService.statusStream.listen((status) {
      if (state.status != status) {
        state = state.copyWith(status: status);
      }
    });
  }

  /// Manually check current connectivity status
  Future<void> checkConnectivity() async {
    final status = await _connectivityService.checkConnectivity();
    if (state.status != status) {
      state = state.copyWith(status: status);
    }
  }
}

/// Provider for the ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();

  // Properly dispose the service when the provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for the ConnectivityState
final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, ConnectivityState>(
      ConnectivityNotifier.new,
    );
