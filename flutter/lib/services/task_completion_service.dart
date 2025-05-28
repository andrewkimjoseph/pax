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
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/providers/local/task_completion_state_provider.dart';

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

      // Update state to complete with the result
      ref
          .read(taskCompletionProvider.notifier)
          .completeTask(taskCompletionResult);

      // Create achievements
      final authState = ref.read(authProvider);
      if (authState.state == AuthState.authenticated) {
        // Get existing achievements
        final achievements = ref.read(achievementProvider).achievements;
        final hasTaskStarter = achievements.any(
          (a) => a.name == 'Task Starter',
        );
        final taskExpert =
            achievements.where((a) => a.name == 'Task Expert').firstOrNull;

        // Only create Task Starter if it's their first task
        if (!hasTaskStarter) {
          await ref
              .read(achievementProvider.notifier)
              .createAchievement(
                timeCreated: Timestamp.now(),
                participantId: authState.user.uid,
                name: 'Task Starter',
                tasksNeededForCompletion: 1,
                tasksCompleted: 1,
                timeCompleted: Timestamp.now(),
                amountEarned: 100,
              );
          ref.read(analyticsProvider).achievementCreated({
            'achievementName': 'Task Starter',
            'amountEarned': 100,
          });
          final fcmToken = await ref.read(fcmTokenProvider.future);
          ref
              .read(notificationServiceProvider)
              .sendAchievementEarnedNotification(
                token: fcmToken!,
                achievementData: {
                  'achievementName': 'Task Starter',
                  'amountEarned': 100,
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
                name: 'Task Expert',
                tasksNeededForCompletion: 10,
                tasksCompleted: 1,
                amountEarned: 1000,
              );
          ref.read(analyticsProvider).achievementCreated({
            'achievementName': 'Task Expert',
            'amountEarned': 1000,
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

            ref.read(analyticsProvider).achievementCompleted({
              'achievementName': 'Task Expert',
              'tasksCompleted': newTasksCompleted,
              'tasksNeededForCompletion': taskExpert.tasksNeededForCompletion,
            });

            final fcmToken = await ref.read(fcmTokenProvider.future);
            ref
                .read(notificationServiceProvider)
                .sendAchievementEarnedNotification(
                  token: fcmToken!,
                  achievementData: {
                    'achievementName': 'Task Expert',
                    'amountEarned': 1000,
                  },
                );
          }

          await ref
              .read(achievementProvider.notifier)
              .updateAchievement(taskExpert.id, updateData);
          ref.read(analyticsProvider).achievementUpdated({
            'achievementName': 'Task Expert',
            'tasksCompleted': newTasksCompleted,
            'tasksNeededForCompletion': taskExpert.tasksNeededForCompletion,
          });
        }

        await ref
            .read(achievementProvider.notifier)
            .fetchAchievements(authState.user.uid);

        ref.invalidate(activityRepositoryProvider);
      }
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
