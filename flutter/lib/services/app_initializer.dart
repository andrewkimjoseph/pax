// This service handles the initialization of core app functionality:
// - Firebase initialization with platform-specific options
// - Error handling setup with Crashlytics integration
// - Push notification setup with background message handling
// Uses a singleton pattern to ensure initialization happens only once

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/firebase_options.dart';
import 'package:pax/services/notifications/notification_service.dart';

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  Future<void> initialize() async {
    await _initializeFirebase();
    await _setupErrorHandling();
    await _initializeNotifications();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<void> _setupErrorHandling() async {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  Future<void> _initializeNotifications() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationService().initialize();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
    print('Background message notification: ${message.notification?.title}');
    print('Background message data: ${message.data}');
  }
}
