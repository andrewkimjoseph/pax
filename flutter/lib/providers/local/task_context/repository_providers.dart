// This file contains repository providers that are used by the task context providers.
// These providers give access to the data repositories needed for:
// - Task data access
// - Screening data access
// - Task completion data access
//
// These repositories are used by the task context providers to fetch and maintain
// real-time data from Firestore.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pax/repositories/firestore/tasks/tasks_repository.dart';
import 'package:pax/repositories/local/screening_repository.dart';
import 'package:pax/repositories/local/task_completions_repository.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for the tasks repository.
/// This repository handles all task-related data operations.
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return TasksRepository(firestore: firestore);
});

/// Provider for the screenings repository.
/// This repository handles all screening-related data operations.
final screeningsRepositoryProvider = Provider<ScreeningsRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ScreeningsRepository(firestore: firestore);
});

/// Provider for the task completions repository.
/// This repository handles all task completion-related data operations.
final taskCompletionsRepositoryProvider = Provider<TaskCompletionsRepository>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return TaskCompletionsRepository(firestore: firestore);
});
