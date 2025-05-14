// lib/providers/tasks/tasks_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/task/task_model.dart';
import 'package:pax/repositories/db/tasks/tasks_repository.dart';

// Provider for the tasks repository
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

// Stream provider for all tasks
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  return repository.getTasks();
});

// Stream provider for available tasks only
final availableTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  return repository.getAvailableTasks();
});
