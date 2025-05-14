// lib/models/task_completion/task_completion_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCompletion {
  final String id;
  final String? taskId;
  final String? screeningId;
  final String? participantId;
  final Timestamp? timeCompleted;

  TaskCompletion({
    required this.id,
    this.taskId,
    this.screeningId,
    this.participantId,
    this.timeCompleted,
  });

  factory TaskCompletion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Task completion data is null');
    }

    return TaskCompletion(
      id: doc.id,
      taskId: data['taskId'],
      screeningId: data['screeningId'],
      participantId: data['participantId'],
      timeCompleted: data['timeCompleted'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'screeningId': screeningId,
      'participantId': participantId,
      'timeCompleted': timeCompleted,
    };
  }
}
