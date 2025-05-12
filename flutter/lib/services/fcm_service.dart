// services/fcm_service.dart - Updated version with duplicate cleanup
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pax/repositories/db/fcm_token/fcm_token_repository.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FcmTokenRepository _tokenRepository;

  FcmService(this._tokenRepository);

  // Initialize FCM and request permission
  Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      print('FCM Permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  // Get the current FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Save the FCM token for a participant
  Future<void> saveTokenForParticipant(String participantId) async {
    try {
      // Get the current token
      final token = await getToken();

      if (token != null && token.isNotEmpty) {
        // Save to Firestore with duplicate prevention
        await _tokenRepository.saveToken(participantId, token);

        // Clean up any duplicate tokens
        await _tokenRepository.cleanupDuplicateTokens(participantId);

        print('FCM token saved for participant: $participantId');
      } else {
        print('Failed to get FCM token');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Listen for token refreshes and save the new token
  void listenForTokenRefresh(String participantId) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('FCM token refreshed');
      await _tokenRepository.saveToken(participantId, newToken);

      // Clean up any duplicate tokens
      await _tokenRepository.cleanupDuplicateTokens(participantId);
    });
  }
}
