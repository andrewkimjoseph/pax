import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/models/auth/auth_user_model.dart';
import 'package:pax/repositories/auth/auth_repository.dart';

class AuthNotifier extends Notifier<AuthStateModel> {
  late final AuthRepository _repository;
  StreamSubscription? _authStateSubscription;
  Timer? _tokenRefreshTimer;

  @override
  AuthStateModel build() {
    _repository = ref.watch(authRepositoryProvider);

    // Start subscription in a microtask to avoid async operations during build
    Future.microtask(() => _startListeningToAuthChanges());

    // Handle disposal of resources when the provider is disposed
    ref.onDispose(() {
      _authStateSubscription?.cancel();
      _cancelTokenValidation();
    });

    return AuthStateModel.initial();
  }

  // Start listening to Firebase auth state changes
  void _startListeningToAuthChanges() {
    _authStateSubscription = _repository.authStateChanges.listen((user) {
      if (user != null) {
        state = state.copyWith(user: user, state: AuthState.authenticated);
        // Start periodic validation when user is authenticated
        _startTokenValidation();
      } else {
        state = state.copyWith(
          user: AuthUser.empty(),
          state: AuthState.unauthenticated,
        );
        // Cancel validation when user is signed out
        _cancelTokenValidation();
      }
    });
  }

  // Start periodic token validation
  void _startTokenValidation() {
    // Cancel any existing timer
    _cancelTokenValidation();

    // Check token validity every 5 minutes
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _validateCurrentUser();
    });
  }

  // Cancel token validation timer
  void _cancelTokenValidation() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  // Validate if the current user is still valid
  Future<void> _validateCurrentUser() async {
    try {
      // Skip validation if user is not authenticated
      if (state.state != AuthState.authenticated) return;

      final isValid = await _repository.validateCurrentUser();

      if (!isValid) {
        // User has been deleted on the backend or token is invalid
        // Force sign out locally
        await _repository.signOut();
        state = state.copyWith(
          user: AuthUser.empty(),
          state: AuthState.unauthenticated,
          errorMessage:
              'Your account has been signed out. Please sign in again.',
        );
      }
    } catch (e) {
      // On any error, we'll keep the user signed in but log the error
      if (kDebugMode) {
        print('Error validating user token: $e');
      }
    }
  }

  // Force refresh the user state (useful after resuming the app)
  Future<void> refreshUserState() async {
    try {
      final currentUser = await _repository.getCurrentUser();

      if (currentUser != null) {
        // Validate user token
        final isValid = await _repository.validateCurrentUser();

        if (isValid) {
          state = state.copyWith(
            user: currentUser,
            state: AuthState.authenticated,
          );
        } else {
          // Token is invalid, sign out
          await _repository.signOut();
          state = state.copyWith(
            user: AuthUser.empty(),
            state: AuthState.unauthenticated,
          );
        }
      } else {
        // No current user
        state = state.copyWith(
          user: AuthUser.empty(),
          state: AuthState.unauthenticated,
        );
      }
    } catch (e) {
      // Error with validation, treat as unauthenticated
      state = state.copyWith(
        user: AuthUser.empty(),
        state: AuthState.error,
        errorMessage: 'Unable to verify authentication status: ${e.toString()}',
      );
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      // Set loading state
      state = state.copyWith(state: AuthState.loading);

      // Attempt to sign in
      final user = await _repository.signInWithGoogle();

      // Update state based on result
      if (user != null) {
        state = state.copyWith(user: user, state: AuthState.authenticated);
      } else {
        // User cancelled the sign-in flow
        state = state.copyWith(state: AuthState.unauthenticated);
      }
    } catch (e) {
      // Handle error
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _repository.signOut();
      state = state.copyWith(
        user: AuthUser.empty(),
        state: AuthState.unauthenticated,
      );
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// Provider for the repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// NotifierProvider for auth state
final authProvider = NotifierProvider<AuthNotifier, AuthStateModel>(() {
  return AuthNotifier();
});

final authStateForRouterProvider = Provider<AuthState>((ref) {
  return ref.watch(authProvider).state;
});
