// app_lifecycle_handler.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/services/branch_service.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';

/// A widget that handles app lifecycle events to refresh auth state
/// when the app is resumed from background
class AppLifecycleHandler extends ConsumerStatefulWidget {
  final Widget child;
  final Function(Map<dynamic, dynamic>) onDeepLink;

  const AppLifecycleHandler({
    super.key,
    required this.child,
    required this.onDeepLink,
  });

  @override
  ConsumerState<AppLifecycleHandler> createState() =>
      _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends ConsumerState<AppLifecycleHandler>
    with WidgetsBindingObserver {
  final _branchService = BranchService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _branchService.init(
      deepLinkHandler: widget.onDeepLink,
    ); // Initialize with handler
    _branchService.listenToDeepLinks(); // Start listening after init
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _branchService.dispose(); // Dispose the Branch service
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh remote config
      ref.read(remoteConfigServiceProvider).refreshConfig();

      // Invalidate all remote config providers to force a rebuild
      ref.invalidate(appVersionConfigProvider);
      ref.invalidate(maintenanceConfigProvider);
      ref.invalidate(featureFlagsProvider);

      // Only refresh auth state if we're not already authenticated
      final currentAuthState = ref.read(authProvider);
      if (currentAuthState.state != AuthState.authenticated) {
        ref.read(authProvider.notifier).refreshUserState();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to remote config updates - moved from initState to build
    ref.listen<AsyncValue<RemoteConfigUpdate>>(remoteConfigUpdateProvider, (
      previous,
      next,
    ) {
      if (next is AsyncData) {
        ref.invalidate(appVersionConfigProvider);
        ref.invalidate(maintenanceConfigProvider);
        ref.invalidate(featureFlagsProvider);
      }
    });

    return widget.child;
  }
}
