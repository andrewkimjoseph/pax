// providers/fcm/fcm_provider.dart - Enhanced version with Notifier
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/repositories/db/fcm_token/fcm_token_repository.dart';
import 'package:pax/services/fcm_service.dart';
import 'package:flutter/foundation.dart';

// Provider for the FCM token repository
final fcmTokenRepositoryProvider = Provider<FcmTokenRepository>((ref) {
  return FcmTokenRepository();
});

// Provider for the FCM service
final fcmServiceProvider = Provider<FcmService>((ref) {
  final repository = ref.watch(fcmTokenRepositoryProvider);
  final service = FcmService(repository);

  // Dispose the service when the provider is disposed
  ref.onDispose(() {
    if (kDebugMode) {
      print('FCM Provider: Disposing FCM service');
    }
    service.dispose();
  });

  return service;
});

// State holder for token initialization status
class FcmInitState {
  final bool isInitialized;
  final bool isSavingToken;
  final bool hasError;
  final String? errorMessage;

  const FcmInitState({
    this.isInitialized = false,
    this.isSavingToken = false,
    this.hasError = false,
    this.errorMessage,
  });

  FcmInitState copyWith({
    bool? isInitialized,
    bool? isSavingToken,
    bool? hasError,
    String? errorMessage,
  }) {
    return FcmInitState(
      isInitialized: isInitialized ?? this.isInitialized,
      isSavingToken: isSavingToken ?? this.isSavingToken,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier for FCM initialization using the modern Notifier syntax
class FcmInitNotifier extends Notifier<FcmInitState> {
  bool _hasSetUpAuthListener = false;

  @override
  FcmInitState build() {
    // Initialize on build
    Future.microtask(() => _initialize());

    return const FcmInitState();
  }

  FcmService get _fcmService => ref.watch(fcmServiceProvider);

  Future<void> _initialize() async {
    try {
      if (state.isInitialized) {
        if (kDebugMode) {
          print('FCM Provider: Already initialized, skipping');
        }
        return;
      }

      // Set initializing state
      state = state.copyWith(isSavingToken: true);

      // Initialize FCM
      await _fcmService.initialize();

      // Set up auth listener if not already set up
      if (!_hasSetUpAuthListener) {
        _setUpAuthListener();
        _hasSetUpAuthListener = true;
      }

      // Update state
      state = state.copyWith(isInitialized: true, isSavingToken: false);

      if (kDebugMode) {
        print('FCM Provider: Initialization complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM Provider: Error during initialization: $e');
      }

      state = state.copyWith(
        isSavingToken: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  void _setUpAuthListener() {
    ref.listen<AuthStateModel>(authProvider, (previous, current) {
      // Only act if there's an actual state change
      if (previous?.state != current.state) {
        if (current.state == AuthState.authenticated) {
          if (kDebugMode) {
            print('FCM Provider: Auth state changed to authenticated');
          }

          _saveTokenForCurrentUser(current.user.uid);
        } else if (current.state == AuthState.unauthenticated) {
          if (kDebugMode) {
            print('FCM Provider: Auth state changed to unauthenticated');
          }

          // Stop listening when user signs out
          _fcmService.stopListening();
        }
      }
    });
  }

  Future<void> _saveTokenForCurrentUser(String userId) async {
    if (state.isSavingToken) {
      if (kDebugMode) {
        print(
          'FCM Provider: Already saving token, skipping duplicate operation',
        );
      }
      return;
    }

    try {
      state = state.copyWith(isSavingToken: true);

      // Save token
      await _fcmService.saveTokenForParticipant(userId);

      // Start listening for token refreshes
      _fcmService.listenForTokenRefresh(userId);

      state = state.copyWith(isSavingToken: false);
    } catch (e) {
      if (kDebugMode) {
        print('FCM Provider: Error saving token: $e');
      }

      state = state.copyWith(
        isSavingToken: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // Force retry initialization
  Future<void> retryInitialization() async {
    if (state.isSavingToken) return;

    state = state.copyWith(
      isInitialized: false,
      hasError: false,
      errorMessage: null,
    );

    await _initialize();
  }
}

// Provider for FCM initialization state using NotifierProvider
final fcmInitProvider = NotifierProvider<FcmInitNotifier, FcmInitState>(() {
  return FcmInitNotifier();
});

// Simple provider to get the FCM token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);
  return await fcmService.getToken();
});
