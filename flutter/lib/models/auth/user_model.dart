import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  UserModel({required this.uid, this.email, this.displayName, this.photoURL});

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }

  // Empty user which represents an unauthenticated state
  factory UserModel.empty() {
    return UserModel(uid: '');
  }

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
