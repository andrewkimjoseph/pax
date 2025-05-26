// lib/repositories/tasks/tasks_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/task/task_model.dart';
import 'package:pax/models/firestore/task_completion/task_completion_model.dart';
import 'package:rxdart/rxdart.dart';

class TasksRepository {
  final FirebaseFirestore _firestore;

  // Collection reference for tasks
  late final CollectionReference _tasksCollection;
  late final CollectionReference _taskCompletionsCollection;
  late final CollectionReference _screeningsCollection;

  // Constructor
  TasksRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _tasksCollection = _firestore.collection('tasks');
    _taskCompletionsCollection = _firestore.collection('task_completions');
    _screeningsCollection = _firestore.collection('screenings');
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

  Stream<List<Task>> getAvailableTasks(String? participantId) {
    // Get all available tasks
    Stream<List<Task>> availableTasksStream = _tasksCollection
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        });

    // Get all task completions for this participant
    Stream<List<TaskCompletion>> completionsStream = _taskCompletionsCollection
        .where('participantId', isEqualTo: participantId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskCompletion.fromFirestore(doc))
              .toList();
        });

    // Get all screenings to check for task capacity and participant screenings
    Stream<Map<String, dynamic>> screeningsStream = _screeningsCollection
        .snapshots()
        .map((snapshot) {
          // 1. Count screenings per taskId
          Map<String, int> taskScreeningCounts = {};
          // 2. Track which tasks each participant has been screened for
          Set<String> participantScreenedTaskIds = {};

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) continue;

            String taskId = data['taskId'] as String;
            String screenedParticipantId = data['participantId'] as String;

            // Count all screenings for this task
            taskScreeningCounts[taskId] =
                (taskScreeningCounts[taskId] ?? 0) + 1;

            // Track which tasks this specific participant has been screened for
            if (screenedParticipantId == participantId) {
              participantScreenedTaskIds.add(taskId);
            }
          }

          return {
            'taskScreeningCounts': taskScreeningCounts,
            'participantScreenedTaskIds': participantScreenedTaskIds,
          };
        });

    // Combine all streams to filter tasks
    return Rx.combineLatest3<
      List<Task>,
      List<TaskCompletion>,
      Map<String, dynamic>,
      List<Task>
    >(availableTasksStream, completionsStream, screeningsStream, (
      availableTasks,
      completions,
      screeningsData,
    ) {
      // Separate completions into those with timeCompleted (fully completed)
      // and those without (in progress)
      final fullyCompletedTaskIds =
          completions
              .where((c) => c.timeCompleted != null)
              .map((c) => c.taskId)
              .toSet();

      final inProgressTaskIds =
          completions
              .where((c) => c.timeCompleted == null)
              .map((c) => c.taskId)
              .toSet();

      // Get the screening data
      final taskScreeningCounts =
          screeningsData['taskScreeningCounts'] as Map<String, int>;
      final participantScreenedTaskIds =
          screeningsData['participantScreenedTaskIds'] as Set<String>;

      // Filter tasks based on the updated criteria
      return availableTasks.where((task) {
        // If the task is fully completed by this participant, don't show it
        if (fullyCompletedTaskIds.contains(task.id)) return false;

        // If the task is in progress by this participant, show it
        if (inProgressTaskIds.contains(task.id)) return true;

        // If participant has been screened for this task, show it
        if (participantScreenedTaskIds.contains(task.id)) return true;

        // Check if the task is past due
        if (task.deadline != null &&
            task.deadline!.toDate().isBefore(DateTime.now())) {
          return false;
        }

        // For tasks neither completed, in progress, nor screened by this participant,
        // check if they're full
        int currentScreenings = taskScreeningCounts[task.id] ?? 0;
        bool isFull =
            currentScreenings >= (task.targetNumberOfParticipants ?? 1);

        // Only include tasks that are not full
        return !isFull;
      }).toList();
    });
  } // Stream of available tasks only

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
