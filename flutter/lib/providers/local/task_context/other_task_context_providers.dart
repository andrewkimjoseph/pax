// lib/providers/task_context_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/screening/screening_model.dart';
import 'package:pax/models/firestore/task/task_model.dart';
import 'package:pax/models/firestore/task_completion/task_completion_model.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/db/tasks/task_provider.dart';
import 'package:pax/providers/local/task_context/main_task_context_provider.dart';
import 'package:pax/providers/local/task_context/repository_providers.dart';

/// StreamProvider for a single task by ID
final taskProvider = StreamProvider.family<Task?, String>((ref, taskId) {
  final repository = ref.watch(tasksRepositoryProvider);
  return repository.getTaskById(taskId);
});

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
