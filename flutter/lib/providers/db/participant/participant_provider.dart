// providers/db/participants_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/models/firestore/participant/participant_model.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/repositories/firestore/participant/participants_repository.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/utils/achievement_constants.dart';
import 'package:pax/utils/user_property_constants.dart';

// State for the participant provider
enum ParticipantState { initial, loading, loaded, error }

// Participant state model
class ParticipantStateModel {
  final Participant? participant;
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
    Participant? participant,
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

// Updated Participant notifier using the new Notifier syntax
class ParticipantNotifier extends Notifier<ParticipantStateModel> {
  late final ParticipantsRepository _repository;

  @override
  ParticipantStateModel build() {
    _repository = ref.watch(participantsRepositoryProvider);

    // Set up auth state listener
    ref.listen(authProvider, (previous, next) {
      // When auth state changes
      if (previous?.state != next.state) {
        if (next.state == AuthState.authenticated) {
          // User just signed in, sync participant data
          syncWithAuthState(next);
        } else if (next.state == AuthState.unauthenticated) {
          // User signed out, clear participant data
          clearParticipant();
        }
      }
    });

    // Check initial auth state
    final authState = ref.read(authProvider);

    // Automatically sync with auth state if user is authenticated
    if (authState.state == AuthState.authenticated) {
      // We need to use Future.microtask because we can't use async in build
      Future.microtask(() => syncWithAuthState(authState));
    }

    return ParticipantStateModel.initial();
  }

  // Sync participant data with current auth state
  Future<void> syncWithAuthState([AuthStateModel? authStateModel]) async {
    // Get auth state from provider if not provided
    final authState = authStateModel ?? ref.read(authProvider);

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
    final authState = ref.read(authProvider);

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

      ref.read(analyticsProvider).profileUpdateComplete();

      // Check if this is the first time completing profile
      final isFirstTimeCompletingProfile =
          // Check if all required fields were previously null
          state.participant?.phoneNumber == null &&
          state.participant?.gender == null &&
          state.participant?.dateOfBirth == null &&
          // Check if all required fields are being set now
          data.containsKey('phoneNumber') &&
          data.containsKey('gender') &&
          data.containsKey('dateOfBirth') &&
          // Ensure we're not just updating verification timestamps
          !data.containsKey('goodDollarIdentityTimeLastAuthenticated') &&
          !data.containsKey('goodDollarIdentityExpiryDate');

      if (isFirstTimeCompletingProfile) {
        // Create Profile Perfectionist achievement
        await ref
            .read(achievementsProvider.notifier)
            .createAchievement(
              timeCreated: Timestamp.now(),
              participantId: state.participant!.id,
              name: AchievementConstants.profilePerfectionist,
              tasksNeededForCompletion:
                  AchievementConstants.profilePerfectionistTasksNeeded,
              tasksCompleted: 1,
              timeCompleted: Timestamp.now(),
              amountEarned: AchievementConstants.profilePerfectionistAmount,
            );
        ref.read(analyticsProvider).achievementCreated({
          'achievementName': 'Profile Perfectionist',
          'amountEarned': 400,
        });
        final fcmToken = await ref.read(fcmTokenProvider.future);
        if (fcmToken != null) {
          await ref
              .read(notificationServiceProvider)
              .sendAchievementEarnedNotification(
                token: fcmToken,
                achievementData: {
                  'achievementName': AchievementConstants.profilePerfectionist,
                  'amountEarned':
                      AchievementConstants.profilePerfectionistAmount,
                },
              );
        }
      }

      ref.read(analyticsProvider).identifyUser({
        UserPropertyConstants.phoneNumber: updatedParticipant.phoneNumber,
        UserPropertyConstants.gender: updatedParticipant.gender,
        UserPropertyConstants.dateOfBirth: updatedParticipant.dateOfBirth,
        UserPropertyConstants.country: updatedParticipant.country,
      });

      // Update state with updated participant
      state = state.copyWith(
        participant: updatedParticipant,
        state: ParticipantState.loaded,
      );

      await ref
          .read(achievementsProvider.notifier)
          .fetchAchievements(authState.user.uid);
    } catch (e) {
      // Handle error
      ref.read(analyticsProvider).profileUpdateFailed({
        "error": e.toString().substring(0, e.toString().length.clamp(0, 99)),
      });
      state = state.copyWith(
        state: ParticipantState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Manually refresh participant data from Firestore
  Future<void> refreshParticipant() async {
    final authState = ref.read(authProvider);

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

// NotifierProvider for participant state
final participantProvider =
    NotifierProvider<ParticipantNotifier, ParticipantStateModel>(() {
      return ParticipantNotifier();
    });
