// providers/db/participants_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/models/firestore/participant/participant_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/repositories/db/participant/participants_repository.dart';

// State for the participant provider
enum ParticipantState { initial, loading, loaded, error }

// Participant state model
class ParticipantStateModel {
  final ParticipantModel? participant;
  final ParticipantState state;
  final String? errorMessage;

  ParticipantStateModel({
    this.participant,
    required this.state,
    this.errorMessage,
  });

  // Initial state factory
  factory ParticipantStateModel.initial() {
    return ParticipantStateModel(state: ParticipantState.initial);
  }

  // Copy with method
  ParticipantStateModel copyWith({
    ParticipantModel? participant,
    ParticipantState? state,
    String? errorMessage,
  }) {
    return ParticipantStateModel(
      participant: participant ?? this.participant,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Participant notifier
class ParticipantNotifier extends StateNotifier<ParticipantStateModel> {
  final ParticipantsRepository _repository;
  final Ref _ref;

  ParticipantNotifier(this._repository, this._ref)
    : super(ParticipantStateModel.initial()) {
    // Check initial auth state
    final authState = _ref.read(authProvider);

    // Automatically sync with auth state if user is authenticated
    if (authState.state == AuthState.authenticated) {
      syncWithAuthState(authState);
    }
  }

  // Sync participant data with current auth state
  Future<void> syncWithAuthState([AuthStateModel? authStateModel]) async {
    // Get auth state from provider if not provided
    final authState = authStateModel ?? _ref.read(authProvider);

    // Skip if not authenticated
    if (authState?.state != AuthState.authenticated) {
      state = ParticipantStateModel.initial();
      return;
    }

    try {
      // Set loading state
      state = state.copyWith(state: ParticipantState.loading);

      // Handle the user sign-in in the repository
      final participant = await _repository.handleUserSignIn(authState!.user);

      // Update state with loaded participant
      state = state.copyWith(
        participant: participant,
        state: ParticipantState.loaded,
      );
    } catch (e) {
      // Handle error
      state = state.copyWith(
        state: ParticipantState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Update participant profile fields
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final authState = _ref.read(authProvider);

    try {
      // Ensure we have a participant and user is authenticated
      if (authState.state != AuthState.authenticated ||
          state.participant == null) {
        throw Exception('User must be authenticated to update profile');
      }

      // Set loading state
      state = state.copyWith(state: ParticipantState.loading);

      // Update participant in repository
      final updatedParticipant = await _repository.updateParticipant(
        authState.user.uid,
        data,
      );

      // Update state with updated participant
      state = state.copyWith(
        participant: updatedParticipant,
        state: ParticipantState.loaded,
      );
    } catch (e) {
      // Handle error
      state = state.copyWith(
        state: ParticipantState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Manually refresh participant data from Firestore
  Future<void> refreshParticipant() async {
    final authState = _ref.read(authProvider);

    try {
      // Ensure user is authenticated
      if (authState.state != AuthState.authenticated) {
        throw Exception('User must be authenticated to refresh profile');
      }

      // Set loading state
      state = state.copyWith(state: ParticipantState.loading);

      // Get participant from repository
      final participant = await _repository.getParticipant(authState.user.uid);

      if (participant != null) {
        // Update state with refreshed participant
        state = state.copyWith(
          participant: participant,
          state: ParticipantState.loaded,
        );
      } else {
        // Participant not found, create a new one
        await syncWithAuthState();
      }
    } catch (e) {
      // Handle error
      state = state.copyWith(
        state: ParticipantState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Clear participant data (used when signing out)
  void clearParticipant() {
    state = ParticipantStateModel.initial();
  }
}

// Provider for the participants repository
final participantsRepositoryProvider = Provider<ParticipantsRepository>((ref) {
  return ParticipantsRepository();
});

// StateNotifierProvider for participant state with explicit type annotation
final participantProvider =
    StateNotifierProvider<ParticipantNotifier, ParticipantStateModel>((ref) {
      final repository = ref.watch(participantsRepositoryProvider);

      // Create the notifier
      final notifier = ParticipantNotifier(repository, ref);

      // Set up auth state listener
      ref.listen(authProvider, (previous, next) {
        // When auth state changes
        if (previous?.state != next.state) {
          if (next.state == AuthState.authenticated) {
            // User just signed in, sync participant data
            notifier.syncWithAuthState(next);
          } else if (next.state == AuthState.unauthenticated) {
            // User signed out, clear participant data
            notifier.clearParticipant();
          }
        }
      });

      return notifier;
    });
