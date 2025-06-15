// Repository Providers for Task Context
// -------------------------------------
// This file defines Riverpod providers for accessing the repositories needed by
// the task context feature. These repositories handle all Firestore data operations
// related to tasks, screenings, and task completions. Use these providers to access
// the underlying data sources throughout the app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/repositories/firestore/tasks/tasks_repository.dart';
import 'package:pax/repositories/local/screening_repository.dart';
import 'package:pax/repositories/local/task_completions_repository.dart';

/// Provides access to the [TasksRepository], which manages all task-related
/// Firestore operations such as fetching, streaming, and updating tasks.
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

/// Provides access to the [ScreeningsRepository], which manages all screening-related
/// Firestore operations such as fetching and streaming participant screenings for tasks.
final screeningsRepositoryProvider = Provider<ScreeningsRepository>((ref) {
  return ScreeningsRepository();
});

/// Provides access to the [TaskCompletionsRepository], which manages all task completion-related
/// Firestore operations such as fetching and streaming completion records for tasks.
final taskCompletionsRepositoryProvider = Provider<TaskCompletionsRepository>((
  ref,
) {
  return TaskCompletionsRepository();
});
