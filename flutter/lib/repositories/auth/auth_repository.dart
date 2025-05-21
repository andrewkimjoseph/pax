import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pax/models/auth/auth_user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Track token refreshes to avoid excessive refreshes
  DateTime? _lastTokenRefresh;

  // Get the current user
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      return AuthUser.fromFirebaseUser(user);
    }
    return null;
  }

  // Stream of auth state changes
  Stream<AuthUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      return user != null ? AuthUser.fromFirebaseUser(user) : null;
    });
  }

  // Sign in with Google
  Future<AuthUser?> signInWithGoogle() async {
    try {
      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Get authentication details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        // Mark that we just refreshed the token
        _lastTokenRefresh = DateTime.now();
        return AuthUser.fromFirebaseUser(userCredential.user!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
      rethrow; // Rethrow to let the notifier handle it
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign out: $e');
      }
      // Continue with signout even if there's an error
    }
  }

  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Only reload if we haven't recently refreshed the token
        if (_shouldRefreshToken()) {
          await user.reload();
          _lastTokenRefresh = DateTime.now();
        }
        return AuthUser.fromFirebaseUser(_auth.currentUser!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user: $e');
      }
      return null;
    }
  }

  // Validate if the current user's token is still valid, but with rate limiting
  Future<bool> validateCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Skip getting a fresh token if we've recently refreshed it
      if (!_shouldRefreshToken()) {
        return true; // Assume token is valid if recently refreshed
      }

      // Try to get a fresh ID token, but don't force refresh unless necessary
      // This is gentler and won't fail as often
      String? token;
      try {
        // First try without forcing refresh
        token = await user.getIdToken(false);
        _lastTokenRefresh = DateTime.now();
      } catch (e) {
        // If that fails, then try with force refresh
        if (kDebugMode) {
          print('Gentle token refresh failed, trying forced refresh');
        }
        token = await user.getIdToken(true);
        _lastTokenRefresh = DateTime.now();
      }

      // If we got a token and it's not empty, the user is still valid
      return token != null && token.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      // Only certain error codes should cause logout
      if (e.code == 'user-token-expired' ||
          e.code == 'user-not-found' ||
          e.code == 'user-disabled') {
        if (kDebugMode) {
          print('Firebase auth validation error: ${e.code} - ${e.message}');
        }
        return false;
      }

      // For other Firebase errors, don't log out
      if (kDebugMode) {
        print('Non-critical Firebase auth error: ${e.code} - ${e.message}');
      }
      return true;
    } catch (e) {
      // For network errors or other issues, don't immediately log out
      if (kDebugMode) {
        print('Error validating user token (non-critical): $e');
      }
      return true; // Assume token is valid if we can't check due to errors
    }
  }

  // Helper method to determine if we should refresh the token
  bool _shouldRefreshToken() {
    if (_lastTokenRefresh == null) return true;

    // Only refresh if it's been more than 10 minutes since last refresh
    final timeSinceLastRefresh = DateTime.now().difference(_lastTokenRefresh!);
    return timeSinceLastRefresh.inMinutes > 10;
  }

  // Force token refresh to detect backend changes, but with rate limiting
  Future<bool> forceTokenRefresh() async {
    try {
      final user = _auth.currentUser;
      if (user != null && _shouldRefreshToken()) {
        // This will throw an exception if the user has been deleted
        await user.getIdToken(true);
        _lastTokenRefresh = DateTime.now();
        return true;
      }
      return user != null; // User exists but we didn't need to refresh
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing token: $e');
      }
      // Return false but don't automatically sign out
      return false;
    }
  }
}
