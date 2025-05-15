// lib/repositories/task_completion/task_completion_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/task_completion/task_completion_model.dart';

class TaskCompletionRepository {
  final FirebaseFirestore _firestore;
  final String collectionName = 'task_completions';

  TaskCompletionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get task completions for a participant
  Future<List<TaskCompletion>> getTaskCompletionsForParticipant(
    String participantId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(collectionName)
              .where('participantId', isEqualTo: participantId)
              .orderBy('timeCompleted', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => TaskCompletion.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting task completions: $e');
      }
      // Return empty list on error
      return [];
    }
  }

  // Get a specific task completion by ID
  Future<TaskCompletion?> getTaskCompletion(String id) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();

      if (doc.exists) {
        return TaskCompletion.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting task completion: $e');
      }
      rethrow;
    }
  }

  // Get task completions for a specific task
  Future<List<TaskCompletion>> getTaskCompletionsForTask(String taskId) async {
    try {
      final snapshot =
          await _firestore
              .collection(collectionName)
              .where('taskId', isEqualTo: taskId)
              .orderBy('timeCompleted', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => TaskCompletion.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting task completions for task: $e');
      }
      // Return empty list on error
      return [];
    }
  }
}
