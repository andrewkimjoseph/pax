// This service manages the reward distribution process:
// - Handles participant rewards through Firebase Functions
// - Manages reward state through Riverpod providers
// - Provides error handling and state management for the reward process
// - Returns detailed reward results including transaction hashes

// lib/services/reward_service.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/local/reward_state_provider.dart';

class RewardService {
  final Ref ref;

  RewardService(this.ref);

  Future<RewardResult> rewardParticipant({
    required String taskCompletionId,
  }) async {
    try {
      // Update state to processing
      ref.read(rewardStateProvider.notifier).startRewarding();

      // Call the Firebase function
      final httpsCallable = FirebaseFunctions.instance.httpsCallable(
        'rewardParticipantProxy',
      );
      final result = await httpsCallable.call({
        'taskCompletionId': taskCompletionId,
      });

      // Extract data from the result
      final data = result.data as Map<String, dynamic>;

      // Create RewardResult object
      final rewardResult = RewardResult.fromMap(data);

      // Update state to complete with the result
      ref.read(rewardStateProvider.notifier).completeRewarding(rewardResult);

      return rewardResult;
    } catch (e) {
      // Update state to error with error message
      ref
          .read(rewardStateProvider.notifier)
          .setError(
            e is FirebaseFunctionsException
                ? e.message ?? e.toString()
                : e.toString(),
          );

      // Log the error
      if (kDebugMode) {
        print('Reward process error: $e');
      }

      rethrow;
    }
  }
}

final rewardServiceProvider = Provider<RewardService>((ref) {
  return RewardService(ref);
});
