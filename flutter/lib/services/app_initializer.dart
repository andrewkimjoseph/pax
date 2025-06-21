// This service handles the initialization of core app functionality:
// - Firebase initialization with platform-specific options
// - Error handling setup with Crashlytics integration
// - Push notification setup with background message handling
// Uses a singleton pattern to ensure initialization happens only once

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:pax/firebase_options.dart';
import 'package:pax/services/notifications/notification_service.dart';
import 'package:pax/services/remote_config/remote_config_service.dart';

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  Future<void> initialize() async {
    await _initializeFirebase();
    await _initializeAppCheck();
    await _setupErrorHandling();
    await _initializeNotifications();

    // Initialize Remote Config with retry logic
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        await _initializeRemoteConfig();
        break;
      } catch (e) {
        retryCount++;
        if (kDebugMode) {
          print('Remote Config initialization attempt $retryCount failed: $e');
        }

        if (retryCount == maxRetries) {
          if (kDebugMode) {
            print(
              'Remote Config initialization failed after $maxRetries attempts',
            );
          }
          // Don't rethrow - allow app to continue without Remote Config
          break;
        }

        await Future.delayed(retryDelay);
      }
    }

    await _initializeBranch();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<void> _initializeAppCheck() async {
    int retryCount = 0;
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 1);

    while (retryCount < maxRetries) {
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider:
              kDebugMode
                  ? AndroidProvider.debug
                  : AndroidProvider.playIntegrity,
        );
        break; // Success, exit the retry loop
      } catch (e) {
        retryCount++;
        if (kDebugMode) {
          print('App Check initialization attempt $retryCount failed: $e');
        }

        if (retryCount >= maxRetries) {
          if (kDebugMode) {
            print(
              'App Check initialization failed after $maxRetries attempts. Continuing without App Check.',
            );
          }
          // Don't rethrow - allow app to continue without App Check
          break;
        }

        // Exponential backoff: 1s, 2s, 4s
        final delay = Duration(
          seconds: baseDelay.inSeconds * (1 << (retryCount - 1)),
        );
        await Future.delayed(delay);
      }
    }
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

  Future<void> _initializeRemoteConfig() async {
    await RemoteConfigService().initialize();
  }

  Future<void> _initializeBranch() async {
    await FlutterBranchSdk.init(
      enableLogging: true,
      branchAttributionLevel: BranchAttributionLevel.MINIMAL,
    );
    // Pass your Branch key(s) here, typically from environment variables or a config file
    // branchLinkControlParams: BranchLinkControlParams(live: !kDebugMode),

    if (kDebugMode) {
      print('Branch SDK initialized');
    }
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
