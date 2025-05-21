// lib/models/task_completion/task_completion_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCompletion {
  final String id;
  final String? taskId;
  final String? screeningId;
  final String? participantId;
  final Timestamp? timeCompleted;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;

  TaskCompletion({
    required this.id,
    this.taskId,
    this.screeningId,
    this.participantId,
    this.timeCompleted,
    this.timeCreated,
    this.timeUpdated,
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
      timeCreated: data['timeCreated'],
      timeUpdated: data['timeUpdated'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'screeningId': screeningId,
      'participantId': participantId,
      'timeCompleted': timeCompleted,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
    };
  }

  // Helper method to check if the task is completed
  bool isCompleted() {
    return timeCompleted != null;
  }

  // Create a copy with updated values
  TaskCompletion copyWith({
    String? id,
    String? taskId,
    String? screeningId,
    String? participantId,
    Timestamp? timeCompleted,
    Timestamp? timeCreated,
    Timestamp? timeUpdated,
  }) {
    return TaskCompletion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      screeningId: screeningId ?? this.screeningId,
      participantId: participantId ?? this.participantId,
      timeCompleted: timeCompleted ?? this.timeCompleted,
      timeCreated: timeCreated ?? this.timeCreated,
      timeUpdated: timeUpdated ?? this.timeUpdated,
    );
  }
}
