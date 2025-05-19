// lib/repositories/tasks/tasks_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/task/task_model.dart';

class TasksRepository {
  final FirebaseFirestore _firestore;

  // Collection reference for tasks
  late final CollectionReference _tasksCollection;

  // Constructor
  TasksRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _tasksCollection = _firestore.collection('tasks');
  }

  // Stream of all tasks
  Stream<List<Task>> getTasks() {
    return _tasksCollection
        .orderBy('timeCreated', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        });
  }

  // Stream of available tasks only
  Stream<List<Task>> getAvailableTasks() {
    return _tasksCollection
        .where('isAvailable', isEqualTo: true)
        // .orderBy('timeCreated', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        });
  }

  // Stream of tasks by category
  Stream<List<Task>> getTasksByCategory(String category) {
    return _tasksCollection
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .orderBy('timeCreated', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        });
  }

  // Stream of tasks by difficulty level
  Stream<List<Task>> getTasksByDifficulty(String difficultyLevel) {
    return _tasksCollection
        .where('levelOfDifficulty', isEqualTo: difficultyLevel)
        .where('isAvailable', isEqualTo: true)
        .orderBy('timeCreated', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        });
  }

  // Get a single task by ID
  Stream<Task?> getTaskById(String taskId) {
    return _tasksCollection.doc(taskId).snapshots().map((doc) {
      if (doc.exists) {
        return Task.fromFirestore(doc);
      } else {
        return null;
      }
    });
  }

  // Get the server wallet ID for a task master
  Future<String?> getTaskMasterServerWalletId(String taskId) async {
    try {
      // First, get the task to retrieve the taskMasterId
      DocumentSnapshot taskDoc = await _tasksCollection.doc(taskId).get();

      if (!taskDoc.exists) {
        return null;
      }

      Task task = Task.fromFirestore(taskDoc);
      String? taskMasterId = task.taskMasterId;

      // Now query the pax_accounts collection using the taskMasterId
      DocumentSnapshot accountDoc =
          await _firestore.collection('pax_accounts').doc(taskMasterId).get();

      if (!accountDoc.exists) {
        return null;
      }

      final data = accountDoc.data() as Map<String, dynamic>?;
      return data?['serverWalletId'] as String?;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving task master server wallet ID: $e');
      }
      return null;
    }
  }
}
