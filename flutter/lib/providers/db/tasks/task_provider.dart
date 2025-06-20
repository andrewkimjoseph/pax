// lib/providers/tasks/tasks_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/task/task_model.dart';
import 'package:pax/repositories/firestore/tasks/tasks_repository.dart';

// Provider for the tasks repository
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

// Stream provider for all tasks
// final tasksStreamProvider = StreamProvider.autoDispose<List<Task>>((ref) {
//   final repository = ref.watch(tasksRepositoryProvider);
//   return repository.getTasks();
// });

// Stream provider for available tasks only
final availableTasksStreamProvider = StreamProvider.family
    .autoDispose<List<Task>, String?>((ref, participantId) {
      final repository = ref.watch(tasksRepositoryProvider);
      return repository.getAvailableTasks(participantId);
    });
