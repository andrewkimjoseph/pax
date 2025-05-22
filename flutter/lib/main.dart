import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/routing/service.dart';
import 'package:pax/services/app_initializer.dart';
import 'package:pax/services/notifications/notification_service.dart';
import 'package:pax/theming/theme_provider.dart';
import 'package:pax/widgets/app_lifecycle_handler.dart';
import 'package:pax/widgets/update_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer().initialize();
  runApp(ProviderScope(child: AppLifecycleHandler(child: App())));
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
        print('Navigating to route: $route');
      }
      // Navigate to the specified route
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    ref.watch(fcmInitProvider);
    return ShadcnApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Pax',
      theme: ref.watch(themeProvider),
      builder: (context, child) {
        return Stack(
          children: [
            MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: child ?? const CircularProgressIndicator(),
            ),
            const UpdateDialog(),
          ],
        );
      },
    );
  }
}
