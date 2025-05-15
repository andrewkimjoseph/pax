import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/firebase_options.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/routing/service.dart';
import 'package:pax/widgets/app_lifecycle_handler.dart';
import 'theming/theme_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background message handler before initializing Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Firebase Messaging for foreground notifications
  await _initializeFirebaseMessaging();

  runApp(ProviderScope(child: AppLifecycleHandler(child: App())));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupForegroundMessageHandling();
    _checkForInitialMessage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle foreground messages
  void _setupForegroundMessageHandling() {
    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message received: ${message.messageId}');
        print('Notification: ${message.notification?.title}');
        print('Data: ${message.data}');
      }

      // Handle the message - you could show a custom in-app notification here
      if (message.notification != null) {
        // You can implement a custom notification display here
        // For example, show a toast or a custom dialog
      }
    });
  }

  // Check for initial message (app opened from terminated state via notification)
  Future<void> _checkForInitialMessage() async {
    // Get any message that caused the app to open from a terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      if (kDebugMode) {
        print('App opened from terminated state via notification');
        print('Initial message: ${initialMessage.messageId}');
      }

      // Handle the initial message - typically navigate to a specific screen
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  // Handle message when user taps on notification
  void _handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Handling message tap: ${message.messageId}');
    }

    // Navigate based on data in the message
    if (message.data.containsKey('route')) {
      final route = message.data['route'];
      if (kDebugMode) {
        print('Navigating to route: $route');
      }

      // Navigate to the specified route
      // Use context.go(route) or similar navigation method based on your routing setup
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    ref.watch(fcmInitProvider);
    return ShadcnApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'My App',
      theme: ref.watch(themeProvider),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child ?? CircularProgressIndicator(),
        );
      },
    );
  }
}

// Initialize Firebase Messaging for foreground notifications
Future<void> _initializeFirebaseMessaging() async {
  // Request permission
  NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: false,
        announcement: false,
        carPlay: false,
      );

  if (kDebugMode) {
    print(
      'User notification permission status: ${settings.authorizationStatus}',
    );
  }

  // Set up foreground notification presentation options
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Get the FCM token
  String? token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    print('FCM Token: ${token?.substring(0, 10)}...');
  }

  // Subscribe to topics if needed
  // await FirebaseMessaging.instance.subscribeToTopic('all_users');
}

// This function is called when a message is received while the app is in the background
// It must be a top-level function (not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (when in background)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Log the message
  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
    print('Background message notification: ${message.notification?.title}');
    print('Background message data: ${message.data}');
  }

  // Implement any background message handling logic here
  // Note: This should be kept minimal as it runs in a background isolate
}
