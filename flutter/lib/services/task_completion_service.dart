// lib/services/task_completion_service.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
