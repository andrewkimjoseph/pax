// lib/repositories/tasks/tasks_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/constants/task_timer.dart';
import 'package:pax/models/firestore/task/task_model.dart';
import 'package:pax/models/firestore/task_completion/task_completion_model.dart';
import 'package:pax/utils/country_util.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class TasksRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for tasks
  late final CollectionReference _tasksCollection = _firestore.collection(
    'tasks',
  );
  late final CollectionReference _taskCompletionsCollection = _firestore
      .collection('task_completions');
  late final CollectionReference _screeningsCollection = _firestore.collection(
    'screenings',
  );

  // Constructor
  TasksRepository();

  Stream<List<Task>> getAvailableTasks(
    String? participantId,
    String? participantCountry,
  ) {
    // Build the base query
    Query tasksQuery;
    if (kDebugMode) {
      tasksQuery = _tasksCollection
          .where('isAvailable', isEqualTo: true)
          .where('isTest', isEqualTo: false);
    } else {
      tasksQuery = _tasksCollection
          .where('isTest', isEqualTo: false)
          .where('isAvailable', isEqualTo: true);
    }

    // Get all available tasks
    Stream<List<Task>> availableTasksStream = tasksQuery.snapshots().map((
      snapshot,
    ) {
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
          // 3. Track screening times for tasks
          Map<String, DateTime> participantScreeningTimes = {};

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) continue;

            String taskId = data['taskId'] as String;
            String screenedParticipantId = data['participantId'] as String;
            Timestamp? timeCreated = data['timeCreated'] as Timestamp?;

            // Count all screenings for this task
            taskScreeningCounts[taskId] =
                (taskScreeningCounts[taskId] ?? 0) + 1;

            // Track which tasks this specific participant has been screened for
            if (screenedParticipantId == participantId && timeCreated != null) {
              participantScreenedTaskIds.add(taskId);
              participantScreeningTimes[taskId] = timeCreated.toDate();
            }
          }

          return {
            'taskScreeningCounts': taskScreeningCounts,
            'participantScreenedTaskIds': participantScreenedTaskIds,
            'participantScreeningTimes': participantScreeningTimes,
          };
        });

    // Add a timer stream that emits every second
    final timerStream = Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now().toUtc(),
    );

    // Combine all streams to filter tasks, including the timer
    return Rx.combineLatest4<
      List<Task>,
      List<TaskCompletion>,
      Map<String, dynamic>,
      DateTime,
      List<Task>
    >(availableTasksStream, completionsStream, screeningsStream, timerStream, (
      availableTasks,
      completions,
      screeningsData,
      nowUtc,
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
      final participantScreeningTimes =
          screeningsData['participantScreeningTimes'] as Map<String, DateTime>;

      // Filter tasks based on the updated criteria
      return availableTasks.where((task) {
        // if (kIsWeb) {
        //   if (task.type == 'fillAForm') return false;
        // }
        // Check if screening time has elapsed (45 minutes)
        if (participantScreeningTimes.containsKey(task.id)) {
          final screeningTime = participantScreeningTimes[task.id]!;
          final elapsedMinutes = nowUtc.difference(screeningTime).inMinutes;
          if (elapsedMinutes >= taskTimerDurationMinutes) return false;
        }
        // If the task is fully completed by this participant, don't show it
        if (fullyCompletedTaskIds.contains(task.id)) return false;

        // Check country targeting FIRST (applies to all tasks)
        final targetCountry = task.targetCountry?.toUpperCase();
        if (targetCountry != null && targetCountry != 'ALL') {
          // If participant has no country set, don't show country-specific tasks
          if (participantCountry == null) return false;

          // Convert participant's country name to country code
          // e.g., "Kenya" -> "KE", "Nigeria" -> "NG"
          final participantCountryObj = CountryUtil.getCountryByName(
            participantCountry,
          );
          if (participantCountryObj == null) return false;

          final participantCountryCode =
              participantCountryObj.code.toUpperCase();

          // Split target countries by comma and check if participant's country code is in the list
          final targetCountries =
              targetCountry
                  .split(',')
                  .map((code) => code.trim().toUpperCase())
                  .toList();

          if (!targetCountries.contains(participantCountryCode)) {
            return false;
          }
        }

        // If the task is in progress by this participant, show it
        if (inProgressTaskIds.contains(task.id)) return true;

        // If participant has been screened for this task, show it
        if (participantScreenedTaskIds.contains(task.id)) return true;

        // Check if the task is past due (compare in UTC)
        if (task.deadline != null) {
          final deadlineUtc = task.deadline!.toDate().toUtc();
          if (deadlineUtc.isBefore(nowUtc)) {
            return false;
          }
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
  Stream<Task?> streamTaskById(String? taskId) {
    return _tasksCollection.doc(taskId).snapshots().map((doc) {
      if (doc.exists) {
        return Task.fromFirestore(doc);
      } else {
        return null;
      }
    });
  }

  // Get a single task by ID (Future)
  Future<Task?> getTaskById(String? taskId) async {
    try {
      final doc = await _tasksCollection.doc(taskId).get();
      if (doc.exists) {
        return Task.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving task by id: $e');
      }
      return null;
    }
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
