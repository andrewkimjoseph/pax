import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  AuthUser({required this.uid, this.email, this.displayName, this.photoURL});

  factory AuthUser.fromFirebaseUser(User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }

  // Empty user which represents an unauthenticated state
  factory AuthUser.empty() {
    return AuthUser(uid: '');
  }

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
