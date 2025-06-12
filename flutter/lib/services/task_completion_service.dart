// This service manages the task completion workflow:
// - Handles marking tasks as complete through Firebase Functions
// - Manages task completion state through Riverpod providers
// - Updates activity feed after task completion
// - Provides error handling and state management for the completion process

// lib/services/task_completion_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/providers/local/task_completion_state_provider.dart';
import 'package:pax/utils/achievement_constants.dart';

class TaskCompletionService {
  final Ref ref;

  TaskCompletionService(this.ref);

  Future<void> markTaskAsComplete({
    required String screeningId,
    required String taskId,
  }) async {
    try {
      // Update state to processing
      ref.read(taskCompletionProvider.notifier).startCompletion();

      // Call the Firebase function
      final httpsCallable = FirebaseFunctions.instance.httpsCallable(
        'markTaskCompletionAsComplete',
      );
      final result = await httpsCallable.call({
        'screeningId': screeningId,
        'taskId': taskId,
      });

      // Extract data from the result
      final data = result.data as Map<String, dynamic>;

      // Create TaskCompletionResult object
      final taskCompletionResult = TaskCompletionResult(
        taskCompletionId: data['taskCompletionId'],
        taskId: taskId,
        screeningId: screeningId,
        completedAt: DateTime.now(),
      );

      // Create achievements
      final authState = ref.read(authProvider);

      // Get existing achievements
      final achievements = ref.read(achievementProvider).achievements;
      final hasTaskStarter = achievements.any(
        (a) =>
            a.name == AchievementConstants.taskStarter &&
            a.timeCompleted != null,
      );
      final taskExpert =
          achievements
              .where((a) => a.name == AchievementConstants.taskExpert)
              .firstOrNull;

      // Only create Task Starter if it's their first task
      if (!hasTaskStarter) {
        await ref
            .read(achievementProvider.notifier)
            .createAchievement(
              timeCreated: Timestamp.now(),
              participantId: authState.user.uid,
              name: AchievementConstants.taskStarter,
              tasksNeededForCompletion:
                  AchievementConstants.taskStarterTasksNeeded,
              tasksCompleted: 1,
              timeCompleted: Timestamp.now(),
              amountEarned: AchievementConstants.taskStarterAmount,
            );
        ref.read(analyticsProvider).achievementCreated({
          'achievementName': AchievementConstants.taskStarter,
          'amountEarned': AchievementConstants.taskStarterAmount,
        });
        final fcmToken = await ref.read(fcmTokenProvider.future);
        ref
            .read(notificationServiceProvider)
            .sendAchievementEarnedNotification(
              token: fcmToken!,
              achievementData: {
                'achievementName': AchievementConstants.taskStarter,
                'amountEarned': AchievementConstants.taskStarterAmount,
              },
            );
      }

      // Handle Task Expert achievement
      if (taskExpert == null) {
        // Create new Task Expert achievement if they don't have it
        await ref
            .read(achievementProvider.notifier)
            .createAchievement(
              timeCreated: Timestamp.now(),
              participantId: authState.user.uid,
              name: AchievementConstants.taskExpert,
              tasksNeededForCompletion:
                  AchievementConstants.taskExpertTasksNeeded,
              tasksCompleted: 1,
              amountEarned: AchievementConstants.taskExpertAmount,
            );
        ref.read(analyticsProvider).achievementCreated({
          'achievementName': AchievementConstants.taskExpert,
          'amountEarned': AchievementConstants.taskExpertAmount,
        });
      } else if (taskExpert.tasksCompleted <
          taskExpert.tasksNeededForCompletion) {
        // Update existing Task Expert achievement
        final newTasksCompleted = taskExpert.tasksCompleted + 1;
        final Map<String, dynamic> updateData = {
          'tasksCompleted': newTasksCompleted,
        };

        // Only set timeCompleted if tasks are now completed
        if (newTasksCompleted >= taskExpert.tasksNeededForCompletion) {
          updateData['timeCompleted'] = Timestamp.now();
          updateData['timeUpdated'] = Timestamp.now();

          ref.read(analyticsProvider).achievementComplete({
            'achievementName': AchievementConstants.taskExpert,
            'tasksCompleted': newTasksCompleted,
            'tasksNeededForCompletion': taskExpert.tasksNeededForCompletion,
          });

          final fcmToken = await ref.read(fcmTokenProvider.future);
          ref
              .read(notificationServiceProvider)
              .sendAchievementEarnedNotification(
                token: fcmToken!,
                achievementData: {
                  'achievementName': AchievementConstants.taskExpert,
                  'amountEarned': AchievementConstants.taskExpertAmount,
                },
              );
        }

        await ref
            .read(achievementProvider.notifier)
            .updateAchievement(taskExpert.id, updateData);
        ref.read(analyticsProvider).achievementUpdated({
          'achievementName': AchievementConstants.taskExpert,
          'tasksCompleted': newTasksCompleted,
          'tasksNeededForCompletion': taskExpert.tasksNeededForCompletion,
        });
      }

      await ref
          .read(achievementProvider.notifier)
          .fetchAchievements(authState.user.uid);

      ref.invalidate(activityRepositoryProvider);

      // Update state to complete with the result after all achievement operations
      ref
          .read(taskCompletionProvider.notifier)
          .completeTask(taskCompletionResult);
    } catch (e) {
      // Update state to error with error message
      ref.read(taskCompletionProvider.notifier).setError(e.toString());

      // Log the error
      if (kDebugMode) {
        print('Task completion error: $e');
      }

      rethrow;
    }
  }
}

final taskCompletionServiceProvider = Provider<TaskCompletionService>((ref) {
  return TaskCompletionService(ref);
});
