// providers/fcm/fcm_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/repositories/db/fcm_token/fcm_token_repository.dart';
import 'package:pax/services/fcm_service.dart';

// Provider for the FCM token repository
final fcmTokenRepositoryProvider = Provider<FcmTokenRepository>((ref) {
  return FcmTokenRepository();
});

// Provider for the FCM service
final fcmServiceProvider = Provider<FcmService>((ref) {
  final repository = ref.watch(fcmTokenRepositoryProvider);
  return FcmService(repository);
});

// Provider to initialize FCM service
final fcmInitProvider = FutureProvider<void>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);

  // Initialize FCM
  await fcmService.initialize();

  // Listen for auth state changes to save token
  ref.listen(authProvider, (previous, current) {
    if (current.state == AuthState.authenticated) {
      // User just signed in, save their FCM token
      fcmService.saveTokenForParticipant(current.user.uid);
      // Listen for token refreshes for this user
      fcmService.listenForTokenRefresh(current.user.uid);
    }
  });
});

// Simple provider to get the FCM token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);
  return await fcmService.getToken();
});
