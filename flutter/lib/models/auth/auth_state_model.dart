import 'package:pax/models/auth/user_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

// Auth state with user model and current state
class AuthStateModel {
  final UserModel user;
  final AuthState state;
  final String? errorMessage;

  AuthStateModel({required this.user, required this.state, this.errorMessage});

  // Factory constructor to create initial state
  factory AuthStateModel.initial() {
    return AuthStateModel(user: UserModel.empty(), state: AuthState.initial);
  }

  // Copy with method to easily create new state instances
  AuthStateModel copyWith({
    UserModel? user,
    AuthState? state,
    String? errorMessage,
  }) {
    return AuthStateModel(
      user: user ?? this.user,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
