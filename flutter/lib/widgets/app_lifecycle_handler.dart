// app_lifecycle_handler.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/auth_provider.dart';

/// A widget that handles app lifecycle events to refresh auth state
/// when the app is resumed from background
class AppLifecycleHandler extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleHandler> createState() =>
      _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends ConsumerState<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When app is resumed from background, refresh auth state
      // This helps detect if the user was deleted on the backend while the app was in background
      ref.read(authProvider.notifier).refreshUserState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Usage in your main.dart:
// void main() {
//   runApp(
//     ProviderScope(
//       child: AppLifecycleHandler(
//         child: MyApp(),
//       ),
//     ),
//   );
// }
