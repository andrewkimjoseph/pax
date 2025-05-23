import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pax/repositories/firestore/fcm_token/fcm_token_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FcmTokenRepository _repository;

  String? _currentToken;
  String? _currentUserId;
  bool _isInitialized = false;
  bool _isSavingToken = false;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  NotificationService._internal() : _repository = FcmTokenRepository();

  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) print('Notification Service: Already initialized');
      return;
    }

    try {
      await _initializeLocalNotifications();
      await _initializeFirebaseMessaging();
      _isInitialized = true;
      if (kDebugMode) print('Notification Service: Successfully initialized');
    } catch (e) {
      if (kDebugMode) print('Notification Service: Error initializing: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_main');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) print('Notification tapped: ${response.payload}');
        if (response.payload != null) {
          // Handle navigation based on payload
        }
      },
    );

    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    final settings = await _messaging.requestPermission(
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

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _currentToken = await _messaging.getToken();
    if (kDebugMode) {
      print('FCM Token: ${_currentToken?.substring(0, 10)}...');
    }
  }

  Future<String?> getToken() async {
    try {
      if (!_isInitialized) await initialize();
      final token = await _messaging.getToken();
      _currentToken = token;
      if (kDebugMode) {
        print('Notification Service: Got token: ${token?.substring(0, 10)}...');
      }
      return token;
    } catch (e) {
      if (kDebugMode) print('Notification Service: Error getting token: $e');
      return null;
    }
  }

  Future<void> saveTokenForParticipant(String participantId) async {
    if (_isSavingToken) {
      if (kDebugMode) {
        print('Notification Service: Token save already in progress');
      }
      return;
    }

    _isSavingToken = true;
    _currentUserId = participantId;

    try {
      final token = await getToken();
      if (token == null) {
        if (kDebugMode) {
          print('Notification Service: No token available to save');
        }
        return;
      }

      if (kDebugMode) {
        print(
          'Notification Service: Saving token for participant $participantId',
        );
      }
      await _repository.saveToken(participantId, token);
      if (kDebugMode) print('Notification Service: Token saved successfully');
    } catch (e) {
      if (kDebugMode) print('Notification Service: Error saving token: $e');
    } finally {
      _isSavingToken = false;
    }
  }

  void listenForTokenRefresh(String participantId) {
    _currentUserId = participantId;
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print(
          'Notification Service: Token refreshed: ${newToken.substring(0, 10)}...',
        );
      }
      if (_currentToken != newToken && _currentUserId != null) {
        _currentToken = newToken;
        saveTokenForParticipant(_currentUserId!);
      }
    });
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'ic_main',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  void setupForegroundMessageHandling(Function(RemoteMessage) onMessageTap) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message received: ${message.messageId}');
        print('Notification: ${message.notification?.title}');
        print('Data: ${message.data}');
      }

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showNotification(
          id: notification.hashCode,
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: message.data['route'],
        );
      }
    });
  }

  Future<void> checkForInitialMessage(
    Function(RemoteMessage) onMessageTap,
  ) async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('App opened from terminated state via notification');
        print('Initial message: ${initialMessage.messageId}');
      }
      onMessageTap(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(onMessageTap);
  }

  void dispose() {
    _currentUserId = null;
    _currentToken = null;
  }

  String _formatAmount(dynamic amount) {
    if (amount is num) {
      return amount == amount.toInt()
          ? amount.toInt().toString()
          : amount.toString();
    }
    return amount.toString();
  }

  Map<String, String> _convertDataToStrings(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<void> sendRemoteNotification({
    required String title,
    required String body,
    required String token,
    Map<String, dynamic>? data,
  }) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('sendNotification').call({
        'title': title,
        'body': body,
        'token': token,
        'data': data != null ? _convertDataToStrings(data) : null,
      });

      if (kDebugMode) {
        print('Notification Service: Remote notification sent successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Notification Service: Error sending remote notification: $e');
      }
      rethrow;
    }
  }

  Future<void> sendPaymentMethodLinkedNotification({
    required String token,
    required Map<String, dynamic> paymentData,
  }) async {
    await sendRemoteNotification(
      title: 'Payment Method Linked! 🎉',
      body:
          '${paymentData['paymentMethodName']} wallet has been successfully connected.',
      token: token,
      data: {'type': 'payment_method_linked', ...paymentData},
    );
  }

  Future<void> sendWithdrawalSuccessNotification({
    required String token,
    required Map<String, dynamic> withdrawalData,
  }) async {
    await sendRemoteNotification(
      title: 'Withdrawal Successful! 💸',
      body:
          'Your withdrawal of ${_formatAmount(withdrawalData['amount'])} ${withdrawalData['currencySymbol']} has been processed.',
      token: token,
      data: {'type': 'withdrawal_success', ...withdrawalData},
    );
  }

  Future<void> sendRewardNotification({
    required String token,
    required Map<String, dynamic> rewardData,
  }) async {
    await sendRemoteNotification(
      title: 'Reward Received! 🎉',
      body:
          'You\'ve received ${_formatAmount(rewardData['amount'])} ${rewardData['currencySymbol']} for completing a task.',
      token: token,
      data: {'type': 'reward', ...rewardData},
    );
  }
}
