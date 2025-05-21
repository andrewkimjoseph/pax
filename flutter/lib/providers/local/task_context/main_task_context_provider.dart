// This file contains the core task context providers that manage the currently selected task
// and its associated state. The task context is used throughout the app to maintain
// consistency when working with a specific task.
//
// The main components are:
// - [TaskContext]: Holds the current task data and ID
// - [TaskContextNotifier]: Manages the task context state
// - [taskContextProvider]: The main provider for accessing the task context
// - [currentTaskIdProvider]: A convenience provider for accessing just the task ID

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/task/task_model.dart';

/// A class to hold the current task context when a user selects a task.
/// This context is used throughout the app to maintain consistency when working
/// with a specific task.
class TaskContext {
  /// The unique identifier of the task
  final String taskId;

  /// The complete task data model
  final Task task;

  TaskContext({required this.taskId, required this.task});

  /// Create a copy with updated values. This is used to maintain immutability
  /// while allowing state updates.
  TaskContext copyWith({String? taskId, Task? task}) {
    return TaskContext(taskId: taskId ?? this.taskId, task: task ?? this.task);
  }
}

/// The notifier to manage the task context state.
/// This notifier is responsible for:
/// - Setting the initial task context
/// - Updating the task data
/// - Clearing the context when navigating away
class TaskContextNotifier extends Notifier<TaskContext?> {
  @override
  TaskContext? build() {
    // Initialize with null (no task selected)
    return null;
  }

  /// Set the task context when a user taps on a task.
  /// This should be called when a user selects a task to work on.
  void setTaskContext(String taskId, Task task) {
    state = TaskContext(taskId: taskId, task: task);
  }

  /// Update the task data while maintaining the same task ID.
  /// This is useful when the task data changes but we're still working
  /// with the same task.
  void updateTask(Task updatedTask) {
    if (state == null) return;

    state = state?.copyWith(task: updatedTask);
  }

  /// Clear the state when navigating away from the task.
  /// This should be called when the user is done working with the task.
  void clear() {
    state = null;
  }
}

/// The main provider for accessing the task context.
/// This provider should be used when you need access to both the task ID
/// and the complete task data.
final taskContextProvider = NotifierProvider<TaskContextNotifier, TaskContext?>(
  () => TaskContextNotifier(),
);

/// A convenience provider for accessing just the current task ID.
/// This is useful when you only need the task ID and don't need the
/// complete task data.
final currentTaskIdProvider = Provider<String?>((ref) {
  final taskContext = ref.watch(taskContextProvider);
  return taskContext?.taskId;
});
