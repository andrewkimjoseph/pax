import 'package:flutter/foundation.dart';
import 'package:pax/models/local/activity_model.dart';
import 'package:pax/repositories/firestore/reward/reward_repository.dart';
import 'package:pax/repositories/firestore/task_completion/task_completion_repository.dart';
import 'package:pax/repositories/firestore/withdrawal/withdrawal_repository.dart';

class ActivityRepository {
  final TaskCompletionRepository _taskCompletionRepository;
  final RewardRepository _rewardRepository;
  final WithdrawalRepository _withdrawalRepository;

  ActivityRepository({
    TaskCompletionRepository? taskCompletionRepository,
    RewardRepository? rewardRepository,
    WithdrawalRepository? withdrawalRepository,
  }) : _taskCompletionRepository =
           taskCompletionRepository ?? TaskCompletionRepository(),
       _rewardRepository = rewardRepository ?? RewardRepository(),
       _withdrawalRepository = withdrawalRepository ?? WithdrawalRepository();

  // Get all activities for a participant
  Future<List<Activity>> getAllActivitiesForParticipant(
    String participantId,
  ) async {
    try {
      // Get data for each activity type
      final taskCompletions = await _taskCompletionRepository
          .getTaskCompletionsForParticipant(participantId);
      final rewards = await _rewardRepository.getRewardsForParticipant(
        participantId,
      );
      final withdrawals = await _withdrawalRepository
          .getWithdrawalsForParticipant(participantId);

      // Convert to activities
      final taskCompletionActivities =
          taskCompletions.map((tc) => Activity.fromTaskCompletion(tc)).toList();
      final rewardActivities =
          rewards.map((r) => Activity.fromReward(r)).toList();
      final withdrawalActivities =
          withdrawals.map((w) => Activity.fromWithdrawal(w)).toList();

      // Combine all activities
      final allActivities = [
        ...taskCompletionActivities,
        ...rewardActivities,
        ...withdrawalActivities,
      ];

      // Sort by timestamp (most recent first)
      allActivities.sort((a, b) {
        final timestampA = a.timestamp;
        final timestampB = b.timestamp;

        if (timestampA == null && timestampB == null) return 0;
        if (timestampA == null) return 1;
        if (timestampB == null) return -1;

        return timestampB.compareTo(timestampA);
      });

      return allActivities;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all activities: $e');
      }
      // Return empty list on error
      return [];
    }
  }

  // Get task completion activities for a participant
  Future<List<Activity>> getTaskCompletionActivitiesForParticipant(
    String participantId,
  ) async {
    try {
      final taskCompletions = await _taskCompletionRepository
          .getTaskCompletionsForParticipant(participantId);
      return taskCompletions
          .map((tc) => Activity.fromTaskCompletion(tc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting task completion activities: $e');
      }
      // Return empty list on error
      return [];
    }
  }

  // Get reward activities for a participant
  Future<List<Activity>> getRewardActivitiesForParticipant(
    String participantId,
  ) async {
    try {
      final rewards = await _rewardRepository.getRewardsForParticipant(
        participantId,
      );
      return rewards.map((r) => Activity.fromReward(r)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting reward activities: $e');
      }
      // Return empty list on error
      return [];
    }
  }

  // Get withdrawal activities for a participant
  Future<List<Activity>> getWithdrawalActivitiesForParticipant(
    String participantId,
  ) async {
    try {
      final withdrawals = await _withdrawalRepository
          .getWithdrawalsForParticipant(participantId);
      return withdrawals.map((w) => Activity.fromWithdrawal(w)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting withdrawal activities: $e');
      }
      // Return empty list on error
      return [];
    }
  }
}
