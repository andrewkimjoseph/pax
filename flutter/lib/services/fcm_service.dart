// services/fcm_service.dart - Enhanced version
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/repositories/firestore/fcm_token/fcm_token_repository.dart';

class FcmService {
  final FcmTokenRepository _repository;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Track if service is initialized
  bool _isInitialized = false;

  // Track current token to prevent unnecessary saves
  String? _currentToken;

  // Track if we're currently saving a token to prevent duplicate operations
  bool _isSavingToken = false;

  // Track the current user ID for token refresh handling
  String? _currentUserId;

  // StreamSubscription for token refresh
  StreamSubscription? _tokenRefreshSubscription;

  FcmService(this._repository);

  // Initialize FCM service
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('FCM Service: Already initialized, skipping');
      }
      return;
    }

    try {
      // Request permissions
      await _requestPermissions();

      // Mark as initialized
      _isInitialized = true;

      if (kDebugMode) {
        print('FCM Service: Successfully initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM Service: Error initializing: $e');
      }
      // Don't rethrow - FCM should not block app functionality
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print(
          'FCM Service: Permission request result: ${settings.authorizationStatus}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM Service: Error requesting permissions: $e');
      }
    }
  }

  // Get the current FCM token
  Future<String?> getToken() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final token = await _messaging.getToken();
      _currentToken = token; // Store current token

      if (kDebugMode) {
        print('FCM Service: Got token: ${token?.substring(0, 10)}...');
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        print('FCM Service: Error getting token: $e');
      }
      return null;
    }
  }

  // Save FCM token for a participant with locking to prevent duplicates
  Future<void> saveTokenForParticipant(String participantId) async {
    // If we're already saving a token, don't start another save
    if (_isSavingToken) {
      if (kDebugMode) {
        print('FCM Service: Token save already in progress, skipping');
      }
      return;
    }

    _isSavingToken = true;
    _currentUserId = participantId;

    try {
      // Get the current token
      final token = await getToken();

      if (token == null) {
        if (kDebugMode) {
          print('FCM Service: No token available to save');
        }
        return;
      }

      if (kDebugMode) {
        print('FCM Service: Saving token for participant $participantId');
      }

      // Save the token
      await _repository.saveToken(participantId, token);

      if (kDebugMode) {
        print('FCM Service: Token saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM Service: Error saving token: $e');
      }
    } finally {
      _isSavingToken = false;
    }
  }

  // Listen for token refresh events
  void listenForTokenRefresh(String participantId) {
    // Cancel any existing subscription
    _tokenRefreshSubscription?.cancel();

    // Update current user ID
    _currentUserId = participantId;

    // Listen for token refresh events
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((newToken) {
          if (kDebugMode) {
            print(
              'FCM Service: Token refreshed: ${newToken.substring(0, 10)}...',
            );
          }

          // Only save if token actually changed
          if (_currentToken != newToken && _currentUserId != null) {
            _currentToken = newToken;
            saveTokenForParticipant(_currentUserId!);
          }
        });

    if (kDebugMode) {
      print(
        'FCM Service: Listening for token refreshes for participant $participantId',
      );
    }
  }

  // Stop listening for token refresh events
  void stopListening() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _currentUserId = null;

    if (kDebugMode) {
      print('FCM Service: Stopped listening for token refreshes');
    }
  }

  // Dispose of resources
  void dispose() {
    stopListening();
  }
}
