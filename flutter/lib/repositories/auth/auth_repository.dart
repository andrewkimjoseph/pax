import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pax/models/auth/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get the current user
  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  // Stream of auth state changes
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
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
        return UserModel.fromFirebaseUser(userCredential.user!);
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
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      // Force token refresh to ensure we have the latest auth state
      await _auth.currentUser?.reload();

      final user = _auth.currentUser;
      if (user != null) {
        return UserModel.fromFirebaseUser(user);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user: $e');
      }
      return null;
    }
  }

  // Validate if the current user's token is still valid
  Future<bool> validateCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Try to get a fresh ID token
      // This will fail if the user has been deleted on the backend
      final token = await user.getIdToken(true);

      // If we got a token and it's not empty, the user is still valid
      return token != null && token.isNotEmpty;
    } on FirebaseAuthException catch (_) {
      // Common error codes for invalid users:
      // user-token-expired, user-not-found, user-disabled
      // print('Firebase auth validation error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error validating user: $e');
      }
      return false;
    }
  }

  // Force token refresh to detect backend changes
  Future<void> forceTokenRefresh() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // This will throw an exception if the user has been deleted
        await user.getIdToken(true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing token: $e');
      }
      // Force sign out if token refresh fails
      await signOut();
    }
  }
}
