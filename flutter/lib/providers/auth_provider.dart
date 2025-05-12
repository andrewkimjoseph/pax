import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/models/auth/user_model.dart';
import 'package:pax/repositories/auth_repository.dart';

class AuthNotifier extends StateNotifier<AuthStateModel> {
  final AuthRepository _repository;
  StreamSubscription? _authStateSubscription;
  Timer? _tokenRefreshTimer;

  AuthNotifier(this._repository) : super(AuthStateModel.initial()) {
    _startListeningToAuthChanges();
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
          user: UserModel.empty(),
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
          user: UserModel.empty(),
          state: AuthState.unauthenticated,
          errorMessage:
              'Your account has been signed out. Please sign in again.',
        );
      }
    } catch (e) {
      // On any error, we'll keep the user signed in but log the error
      print('Error validating user token: $e');
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
            user: UserModel.empty(),
            state: AuthState.unauthenticated,
          );
        }
      } else {
        // No current user
        state = state.copyWith(
          user: UserModel.empty(),
          state: AuthState.unauthenticated,
        );
      }
    } catch (e) {
      // Error with validation, treat as unauthenticated
      state = state.copyWith(
        user: UserModel.empty(),
        state: AuthState.error,
        errorMessage: 'Unable to verify authentication status: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _cancelTokenValidation();
    super.dispose();
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

        print(user.displayName);
        print(user.email);
        print(user.photoURL);
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
        user: UserModel.empty(),
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

// StateNotifierProvider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthStateModel>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
