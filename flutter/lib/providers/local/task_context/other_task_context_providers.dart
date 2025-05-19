// lib/providers/task_context_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/screening/screening_model.dart';
import 'package:pax/models/firestore/task/task_model.dart';
import 'package:pax/models/firestore/task_completion/task_completion_model.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/db/tasks/task_provider.dart';
import 'package:pax/providers/local/task_context/repository_providers.dart';

/// StreamProvider for a single task by ID
final taskProvider = StreamProvider.family<Task?, String>((ref, taskId) {
  final repository = ref.watch(tasksRepositoryProvider);
  return repository.getTaskById(taskId);
});

/// StreamProvider for a screening by participant ID and task ID
final screeningProvider =
    StreamProvider.family<Screening?, ({String participantId, String taskId})>((
      ref,
      params,
    ) {
      final repository = ref.watch(screeningsRepositoryProvider);
      return repository.getScreeningByParticipantAndTask(
        params.participantId,
        params.taskId,
      );
    });

/// StreamProvider for a task completion by participant ID and task ID
final taskCompletionProvider = StreamProvider.family<
  TaskCompletion?,
  ({String participantId, String taskId})
>((ref, params) {
  final repository = ref.watch(taskCompletionsRepositoryProvider);
  return repository.getTaskCompletionByParticipantAndTask(
    params.participantId,
    params.taskId,
  );
});

/// Class to hold the selected task context
class TaskContext {
  final String taskId;
  final Task task;

  TaskContext({required this.taskId, required this.task});

  TaskContext copyWith({String? taskId, Task? task}) {
    return TaskContext(taskId: taskId ?? this.taskId, task: task ?? this.task);
  }
}

/// Notifier for the selected task
class TaskContextNotifier extends Notifier<TaskContext?> {
  @override
  TaskContext? build() {
    return null; // Start with no selected task
  }

  /// Set the current task
  void setTask(Task task) {
    state = TaskContext(taskId: task.id, task: task);
  }

  /// Update the task data
  void updateTask(Task updatedTask) {
    if (state == null) return;
    if (state!.taskId != updatedTask.id) return;

    state = state!.copyWith(task: updatedTask);
  }

  /// Clear the selected task
  void clear() {
    state = null;
  }
}

/// Provider for the selected task context
final taskContextProvider = NotifierProvider<TaskContextNotifier, TaskContext?>(
  () {
    return TaskContextNotifier();
  },
);

/// Provider to check if a task is selected
final hasSelectedTaskProvider = Provider<bool>((ref) {
  return ref.watch(taskContextProvider) != null;
});

/// Stream provider for the currently selected task's screening
final selectedTaskScreeningProvider = StreamProvider<Screening?>((ref) {
  final taskContext = ref.watch(taskContextProvider);
  final currentParticipant = ref.watch(
    participantProvider,
  ); // You'll need to define this provider

  if (taskContext == null || currentParticipant.participant == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(screeningsRepositoryProvider);
  return repository.getScreeningByParticipantAndTask(
    currentParticipant.participant!.id,
    taskContext.taskId,
  );
});

/// Stream provider for the currently selected task's completion
final selectedTaskCompletionProvider = StreamProvider<TaskCompletion?>((ref) {
  final taskContext = ref.watch(taskContextProvider);
  final currentParticipant = ref.watch(participantProvider);

  if (taskContext == null || currentParticipant.participant == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(taskCompletionsRepositoryProvider);
  return repository.getTaskCompletionByParticipantAndTask(
    currentParticipant.participant!.id,
    taskContext.taskId,
  );
});

/// Provider to check if the selected task has been screened
final isSelectedTaskScreenedProvider = Provider<bool>((ref) {
  final screeningAsync = ref.watch(selectedTaskScreeningProvider);
  return screeningAsync.maybeWhen(
    data: (screening) => screening != null,
    orElse: () => false,
  );
});

/// Provider to check if the selected task has been completed
final isSelectedTaskCompletedProvider = Provider<bool>((ref) {
  final taskCompletionAsync = ref.watch(selectedTaskCompletionProvider);
  return taskCompletionAsync.maybeWhen(
    data: (taskCompletion) => taskCompletion?.timeCompleted != null,
    orElse: () => false,
  );
});
