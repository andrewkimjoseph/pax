// This file contains derived task context providers that build upon the main task context.
// These providers handle specific aspects of task-related functionality such as:
// - Task data streaming
// - Task selection state
// - Task screening status
// - Task completion status
//
// These providers depend on [taskContextProvider] from main_task_context_provider.dart
// and various repository providers to provide real-time updates and derived state.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/screening/screening_model.dart';
import 'package:pax/models/firestore/task/task_model.dart';
import 'package:pax/models/firestore/task_completion/task_completion_model.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/local/task_context/main_task_context_provider.dart';
import 'package:pax/providers/local/task_context/repository_providers.dart';

/// StreamProvider for a single task by ID.
/// This provider streams real-time updates for a specific task.
/// It uses the tasks repository to fetch and maintain the task data.
final taskProvider = StreamProvider.family<Task?, String>((ref, taskId) {
  final repository = ref.watch(tasksRepositoryProvider);
  return repository.streamTaskById(taskId);
});

/// Provider to check if a task is currently selected.
/// This is a convenience provider that returns true if there is an active task context.
/// Useful for UI elements that need to know if a task is selected.
final hasSelectedTaskProvider = Provider<bool>((ref) {
  return ref.watch(taskContextProvider) != null;
});

/// Stream provider for the currently selected task's screening.
/// This provider streams real-time updates about the screening status of the currently selected task
/// for the current participant. Returns null if no task is selected or no screening exists.
final selectedTaskScreeningProvider = StreamProvider<Screening?>((ref) {
  final taskContext = ref.watch(taskContextProvider);
  final currentParticipant = ref.watch(participantProvider);

  if (taskContext == null || currentParticipant.participant == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(screeningsRepositoryProvider);
  return repository.getScreeningByParticipantAndTask(
    currentParticipant.participant!.id,
    taskContext.taskId,
  );
});

/// Stream provider for the currently selected task's completion.
/// This provider streams real-time updates about the completion status of the currently selected task
/// for the current participant. Returns null if no task is selected or no completion exists.
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

/// Provider to check if the selected task has been screened.
/// This is a convenience provider that returns true if the currently selected task
/// has a screening record. Useful for UI elements that need to show screening status.
final isSelectedTaskScreenedProvider = Provider<bool>((ref) {
  final screeningAsync = ref.watch(selectedTaskScreeningProvider);
  return screeningAsync.maybeWhen(
    data: (screening) => screening != null,
    orElse: () => false,
  );
});

/// Provider to check if the selected task has been completed.
/// This is a convenience provider that returns true if the currently selected task
/// has been completed (has a completion time). Useful for UI elements that need to
/// show completion status.
final isSelectedTaskCompletedProvider = Provider<bool>((ref) {
  final taskCompletionAsync = ref.watch(selectedTaskCompletionProvider);
  return taskCompletionAsync.maybeWhen(
    data: (taskCompletion) => taskCompletion?.timeCompleted != null,
    orElse: () => false,
  );
});
