import 'package:pax/models/auth/auth_user_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

// Auth state with user model and current state
class AuthStateModel {
  final AuthUser user;
  final AuthState state;
  final String? errorMessage;

  AuthStateModel({required this.user, required this.state, this.errorMessage});

  // Factory constructor to create initial state
  factory AuthStateModel.initial() {
    return AuthStateModel(user: AuthUser.empty(), state: AuthState.initial);
  }

  // Copy with method to easily create new state instances
  AuthStateModel copyWith({
    AuthUser? user,
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
