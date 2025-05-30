import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/env/env.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';
import 'package:pax/routing/service.dart';
import 'package:pax/services/app_initializer.dart';
import 'package:pax/services/notifications/notification_service.dart';
import 'package:pax/theming/theme_provider.dart';
import 'package:pax/widgets/app_lifecycle_handler.dart';
import 'package:pax/widgets/maintenance_dialog.dart';
import 'package:pax/widgets/update_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer().initialize();
  runApp(ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupNotifications();
    _initializeAnalytics();
  }

  void _initializeAnalytics() {
    final amplitudeApiKey = Env.amplitudeAPIKey;
    ref.read(analyticsProvider).initialize(amplitudeApiKey);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setupNotifications() {
    _notificationService.setupForegroundMessageHandling(_handleMessage);
    _notificationService.checkForInitialMessage(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data.containsKey('route')) {
      final route = message.data['route'];
      if (kDebugMode) {
        print('Navigating to route from FCM: $route');
      }
      final router = ref.read(routerProvider);
      router.push(route);
    }
  }

  void _handleDeepLink(Map<dynamic, dynamic> linkData) {
    if (kDebugMode) {
      print('Handling deep link in App: $linkData');
    }

    final router = ref.read(routerProvider);

    // Only handle navigation if it's a valid Branch link
    if (linkData['+clicked_branch_link'] == true) {
      // Extract the path from the referring link
      String? path;
      if (linkData.containsKey('~referring_link')) {
        final url = Uri.parse(linkData['~referring_link'] as String);
        if (url.path.isNotEmpty) {
          path = url.path;
        }
      }

      // If we have a valid path, navigate to it
      if (path != null && path.isNotEmpty) {
        // First navigate to home to ensure proper navigation stack
        router.go("/home");
        // Then push the target route
        router.push(path);
      } else {
        router.go("/home");
      }
    } else {
      // If not a valid Branch link, just go to home
      router.go("/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    ref.watch(fcmInitProvider);

    // Watch for app version config changes
    ref.listen(appVersionConfigProvider, (previous, next) {
      next.whenData((config) {
        if (config.forceUpdate) {
          // The dialog will be built within the widget tree,
          // so no need to explicitly showDialog here anymore.
        }
      });
    });

    return AppLifecycleHandler(
      onDeepLink: _handleDeepLink, // Pass the deep link handler callback
      child: ShadcnApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: 'Pax',
        theme: ref.watch(themeProvider),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: Stack(
              children: [
                child ?? const CircularProgressIndicator(),
                // The UpdateDialog is now a widget within the tree,
                // controlling its own visibility based on config.
                const UpdateDialog(),
                // The MaintenanceDialog is also a widget within the tree,
                // controlling its own visibility based on config.
                const MaintenanceDialog(),
              ],
            ),
          );
        },
      ),
    );
  }
}
