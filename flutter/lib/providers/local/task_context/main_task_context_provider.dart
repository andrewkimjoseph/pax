import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/task/task_model.dart';

/// A class to hold the current task context when a user selects a task
class TaskContext {
  final String taskId;
  final Task task;

  TaskContext({required this.taskId, required this.task});

  /// Create a copy with updated values
  TaskContext copyWith({String? taskId, Task? task}) {
    return TaskContext(taskId: taskId ?? this.taskId, task: task ?? this.task);
  }
}

/// The notifier to manage the task context state
class TaskContextNotifier extends Notifier<TaskContext?> {
  @override
  TaskContext? build() {
    // Initialize with null (no task selected)
    return null;
  }

  /// Set the task context when a user taps on a task
  void setTaskContext(String taskId, Task task) {
    state = TaskContext(taskId: taskId, task: task);
  }

  /// Update the task data
  void updateTask(Task updatedTask) {
    if (state == null) return;

    state = state?.copyWith(task: updatedTask);
  }

  /// Clear the state when navigating away from the task
  void clear() {
    state = null;
  }
}

/// Create the provider
final taskContextProvider = NotifierProvider<TaskContextNotifier, TaskContext?>(
  () => TaskContextNotifier(),
);

/// Provider to get the current task ID if available
final currentTaskIdProvider = Provider<String?>((ref) {
  final taskContext = ref.watch(taskContextProvider);
  return taskContext?.taskId;
});
