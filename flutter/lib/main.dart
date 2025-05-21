import 'dart:io';

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
// Add these imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Create a top-level variable for the local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Define notification channel for Android
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local notifications
  await _initializeLocalNotifications();

  // Register background message handler before initializing Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Firebase Messaging for foreground notifications
  await _initializeFirebaseMessaging();

  runApp(ProviderScope(child: AppLifecycleHandler(child: App())));
}

// Initialize local notifications
Future<void> _initializeLocalNotifications() async {
  // Initialize settings for Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('main_notif'); // Using your custom icon

  // Initialize settings for iOS
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  // Initialize settings for both platforms
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // Initialize the plugin
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
      if (kDebugMode) {
        print('Notification tapped: ${response.payload}');
      }

      // You can navigate to specific screens based on the payload
      if (response.payload != null) {
        // Navigate based on payload
        // e.g., context.go(response.payload) if using go_router
      }
    },
  );

  // Create the notification channel (for Android only)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
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

      // Show a local notification when the app is in the foreground
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'main_notif', // Using your custom icon
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['route'],
        );
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

  // Method to show a local notification (you can call this from anywhere in your app)

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

  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // Create the channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

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
}

@pragma('vm:entry-point')
Future<void> showLocalNotification({
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: 'main_notif',
      ),
      iOS: const DarwinNotificationDetails(),
    ),
    payload: payload,
  );
}
