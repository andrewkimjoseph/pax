// lib/providers/repositories_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pax/repositories/local/screening_repository.dart';
import 'package:pax/repositories/local/task_completions_repository.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for ScreeningsRepository
final screeningsRepositoryProvider = Provider<ScreeningsRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ScreeningsRepository(firestore: firestore);
});

/// Provider for TaskCompletionsRepository
final taskCompletionsRepositoryProvider = Provider<TaskCompletionsRepository>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return TaskCompletionsRepository(firestore: firestore);
});
