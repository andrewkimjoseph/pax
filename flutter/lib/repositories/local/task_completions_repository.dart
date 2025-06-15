// lib/repositories/task_completions/task_completions_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pax/models/firestore/task_completion/task_completion_model.dart';

class TaskCompletionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for task completions
  late final CollectionReference _taskCompletionsCollection = _firestore
      .collection('task_completions');

  // Constructor
  TaskCompletionsRepository();

  // Stream of task completion for a specific participant and task
  Stream<TaskCompletion?> getTaskCompletionByParticipantAndTask(
    String participantId,
    String taskId,
  ) {
    return _taskCompletionsCollection
        .where('participantId', isEqualTo: participantId)
        .where('taskId', isEqualTo: taskId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }
          return TaskCompletion.fromFirestore(snapshot.docs.first);
        });
  }
}
