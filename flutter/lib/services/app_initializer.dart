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
import 'package:pax/services/branch_service.dart';
import 'package:pax/services/notifications/notification_service.dart';
import 'package:pax/services/remote_config/remote_config_service.dart';

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  Future<void> initialize() async {
    // Critical path: Initialize Firebase first (required for everything else)
    await _initializeFirebase();

    // Parallelize independent initializations
    await Future.wait([
      _setupErrorHandling(),
      _initializeAppCheck(),
      _initializeNotifications(),
    ]);

    // Defer non-critical services - they'll initialize in background
    // This allows the app to start faster
    _initializeNonCriticalServices();
  }

  /// Initialize only Firebase (for web fast startup)
  Future<void> initializeFirebaseOnly() async {
    await _initializeFirebase();
    _setupErrorHandling(); // Non-blocking, just sets up handlers
  }

  /// Initialize remaining services after app has started (for web)
  Future<void> initializeRemaining() async {
    // Parallelize independent initializations
    await Future.wait([_initializeAppCheck(), _initializeNotifications()]);

    // Defer non-critical services
    _initializeNonCriticalServices();
  }

  /// Initialize non-critical services in the background
  /// These don't block app startup
  void _initializeNonCriticalServices() {
    // Use unawaited to prevent blocking
    _initializeRemoteConfigBackground();
    if (!kIsWeb) {
      // Branch SDK is not needed on web (handled in index.html)
      _initializeBranchBackground();
    }
  }

  Future<void> _initializeRemoteConfigBackground() async {
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
  }

  Future<void> _initializeBranchBackground() async {
    try {
      await _initializeBranch();
    } catch (e) {
      if (kDebugMode) {
        print('Branch SDK initialization failed: $e');
      }
      // Don't block app startup if Branch fails
    }
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<void> _initializeAppCheck() async {
    // App Check is less critical and can fail gracefully
    // Use a shorter timeout on web for faster startup
    try {
      await FirebaseAppCheck.instance
          .activate(
            androidProvider:
                kDebugMode
                    ? AndroidProvider.debug
                    : AndroidProvider.playIntegrity,
          )
          .timeout(
            Duration(seconds: kIsWeb ? 3 : 10),
            onTimeout: () {
              if (kDebugMode) {
                print(
                  'App Check initialization timed out. Continuing without App Check.',
                );
              }
            },
          );
    } catch (e) {
      if (kDebugMode) {
        print(
          'App Check initialization failed: $e. Continuing without App Check.',
        );
      }
      // Don't rethrow - allow app to continue without App Check
    }
  }

  Future<void> _setupErrorHandling() async {
    FlutterError.onError = (errorDetails) {
      // On web, Crashlytics may not be available or needed
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      } else {
        // Log to console on web for debugging
        if (kDebugMode) {
          print('Flutter Error: ${errorDetails.exception}');
          print('Stack: ${errorDetails.stack}');
        }
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } else {
        // Log to console on web for debugging
        if (kDebugMode) {
          print('Platform Error: $error');
          print('Stack: $stack');
        }
      }
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
    await FlutterBranchSdk.init(enableLogging: true);

    // Notify BranchService that SDK is ready
    BranchService.markSdkInitialized();

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
