// Task Context Providers
// ----------------------
// This file defines Riverpod providers and state notifiers for managing the current task context
// in the app. The task context tracks the currently selected task, its state, and related data
// such as screening and completion status for the current participant. Use these providers to
// access and react to task-specific state throughout the app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/task/task_model.dart';
import 'package:pax/models/firestore/screening/screening_model.dart';
import 'package:pax/models/firestore/task_completion/task_completion_model.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/local/task_context/repository_providers.dart';

/// Holds the current task context, including the selected task's ID and data.
/// Used throughout the app to maintain consistency when working with a specific task.
class TaskContext {
  /// The unique identifier of the selected task.
  final String taskId;

  /// The complete data model for the selected task.
  final Task task;

  TaskContext({required this.taskId, required this.task});

  /// Returns a copy of this context with updated values.
  TaskContext copyWith({String? taskId, Task? task}) {
    return TaskContext(taskId: taskId ?? this.taskId, task: task ?? this.task);
  }
}

/// Notifier for managing the [TaskContext] state.
/// Handles selecting, updating, and clearing the current task context.
class TaskContextNotifier extends Notifier<TaskContext?> {
  @override
  TaskContext? build() {
    // No task selected by default.
    return null;
  }

  /// Set the current task context when a user selects a task.
  void setTaskContext(String taskId, Task task) {
    state = TaskContext(taskId: taskId, task: task);
  }

  /// Update the task data for the current context.
  void updateTask(Task updatedTask) {
    if (state == null) return;
    state = state?.copyWith(task: updatedTask);
  }

  /// Clear the current task context (e.g., when navigating away).
  void clear() {
    state = null;
  }
}

/// Provides access to the current [TaskContext].
/// Use this provider to get both the selected task's ID and its data.
final taskContextProvider = NotifierProvider<TaskContextNotifier, TaskContext?>(
  () => TaskContextNotifier(),
);

/// Provides the ID of the currently selected task, or null if none is selected.
final currentTaskIdProvider = Provider<String?>((ref) {
  final taskContext = ref.watch(taskContextProvider);
  return taskContext?.taskId;
});

// -----------------------------------------------------------------------------
// Derived Task Context Providers
// -----------------------------------------------------------------------------
// These providers build on [taskContextProvider] and repository providers to offer
// real-time updates and derived state for the selected task, such as streaming the
// latest task data, screening status, and completion status for the current participant.

/// Streams real-time updates for a single task by ID using the [TasksRepository].
final taskProvider = StreamProvider.family.autoDispose<Task?, String>((
  ref,
  taskId,
) {
  final repository = ref.watch(tasksRepositoryProvider);
  return repository.streamTaskById(taskId);
});

/// Returns true if a task is currently selected.
final hasSelectedTaskProvider = Provider<bool>((ref) {
  return ref.watch(taskContextProvider) != null;
});

/// Streams the screening record for the selected task and current participant, if any.
/// Returns null if no task is selected or no screening exists.
final selectedTaskScreeningProvider = StreamProvider<Screening?>((ref) {
  final taskContext = ref.watch(taskContextProvider);
  final participantState = ref.read(participantProvider);
  final participant = participantState.participant;

  if (taskContext == null || participant == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(screeningsRepositoryProvider);
  return repository.getScreeningByParticipantAndTask(
    participant.id,
    taskContext.taskId,
  );
});

/// Streams the completion record for the selected task and current participant, if any.
/// Returns null if no task is selected or no completion exists.
final selectedTaskCompletionProvider = StreamProvider<TaskCompletion?>((ref) {
  final taskContext = ref.watch(taskContextProvider);
  final participantState = ref.read(participantProvider);
  final participant = participantState.participant;

  if (taskContext == null || participant == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(taskCompletionsRepositoryProvider);
  return repository.getTaskCompletionByParticipantAndTask(
    participant.id,
    taskContext.taskId,
  );
});

/// Returns true if the selected task has a screening record for the current participant.
final isSelectedTaskScreenedProvider = Provider<bool>((ref) {
  final screeningAsync = ref.watch(selectedTaskScreeningProvider);
  return screeningAsync.maybeWhen(
    data: (screening) => screening != null,
    orElse: () => false,
  );
});

/// Returns true if the selected task has been completed by the current participant.
final isSelectedTaskCompletedProvider = Provider<bool>((ref) {
  final taskCompletionAsync = ref.watch(selectedTaskCompletionProvider);
  return taskCompletionAsync.maybeWhen(
    data: (taskCompletion) => taskCompletion?.timeCompleted != null,
    orElse: () => false,
  );
});
