import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/models/auth/auth_user_model.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/providers/route/home_selected_index_provider.dart';
import 'package:pax/providers/route/root_selected_index_provider.dart';
import 'package:pax/repositories/auth/auth_repository.dart';

class AuthNotifier extends Notifier<AuthStateModel> {
  late final AuthRepository _repository;
  StreamSubscription? _authStateSubscription;
  Timer? _tokenRefreshTimer;

  // Track consecutive validation failures
  int _consecutiveValidationFailures = 0;
  static const int _maxConsecutiveFailures = 3;

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
        // Reset consecutive failures when user successfully authenticates
        _consecutiveValidationFailures = 0;
        // Start periodic validation when user is authenticated
        _startTokenValidation();
      } else {
        // Only change to unauthenticated if we were previously authenticated
        // This prevents multiple sign-out events
        if (state.state == AuthState.authenticated) {
          state = state.copyWith(
            user: AuthUser.empty(),
            state: AuthState.unauthenticated,
          );
          // Cancel validation when user is signed out
          _cancelTokenValidation();
        }
      }
    });
  }

  // Start periodic token validation with a longer interval
  void _startTokenValidation() {
    // Cancel any existing timer
    _cancelTokenValidation();

    // Check token validity every 30 minutes instead of 5
    // This reduces the frequency of validation attempts
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _validateCurrentUser();
    });
  }

  // Cancel token validation timer
  void _cancelTokenValidation() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  // Validate if the current user is still valid with failure tolerance
  Future<void> _validateCurrentUser() async {
    try {
      // Skip validation if user is not authenticated
      if (state.state != AuthState.authenticated) return;

      final isValid = await _repository.validateCurrentUser();

      if (isValid) {
        // Reset failure counter on successful validation
        _consecutiveValidationFailures = 0;
      } else {
        // Increment failure counter
        _consecutiveValidationFailures++;

        // Only log out after multiple consecutive failures
        if (_consecutiveValidationFailures >= _maxConsecutiveFailures) {
          if (kDebugMode) {
            print('Multiple consecutive validation failures. Logging out.');
          }

          await _repository.signOut();
          state = state.copyWith(
            user: AuthUser.empty(),
            state: AuthState.unauthenticated,
            errorMessage: 'Your session has expired. Please sign in again.',
          );
        } else {
          if (kDebugMode) {
            print(
              'Validation failure $_consecutiveValidationFailures/$_maxConsecutiveFailures. Not logging out yet.',
            );
          }
        }
      }
    } catch (e) {
      // On any error, log the error but don't count it as a validation failure
      // This prevents network errors from causing logouts
      if (kDebugMode) {
        print('Error during token validation: $e');
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
          // Reset consecutive failures on successful refresh
          _consecutiveValidationFailures = 0;
        } else {
          // Increment failure counter
          _consecutiveValidationFailures++;

          // Only log out after multiple consecutive failures
          if (_consecutiveValidationFailures >= _maxConsecutiveFailures) {
            // Token is invalid, sign out
            await _repository.signOut();
            state = state.copyWith(
              user: AuthUser.empty(),
              state: AuthState.unauthenticated,
            );
          }
        }
      } else {
        // No current user
        state = state.copyWith(
          user: AuthUser.empty(),
          state: AuthState.unauthenticated,
        );
      }
    } catch (e) {
      // Error with validation, but don't automatically log out
      // Just log the error and continue
      if (kDebugMode) {
        print('Error refreshing user state: $e');
      }
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
        // Reset consecutive failures on successful sign in
        _consecutiveValidationFailures = 0;

        ref.read(analyticsProvider).setUserId(user.uid);
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

      ref.read(homeSelectedIndexProvider.notifier).reset();
      ref.read(rootSelectedIndexProvider.notifier).reset();
      ref.invalidate(achievementsProvider);
      ref.read(analyticsProvider).resetUser();

      state = state.copyWith(
        user: AuthUser.empty(),
        state: AuthState.unauthenticated,
      );
    } catch (e) {
      // Even if there's an error, still update the local state to unauthenticated
      // This ensures the user is logged out even if the backend call fails
      state = state.copyWith(
        user: AuthUser.empty(),
        state: AuthState.unauthenticated,
      );

      if (kDebugMode) {
        print('Error during sign out: $e');
      }
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
