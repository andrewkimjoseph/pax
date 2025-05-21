// lib/providers/local/task_completion_state_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TaskCompletionState { initial, processing, complete, error }

class TaskCompletionResult {
  final String taskCompletionId;
  final String taskId;
  final String screeningId;
  final DateTime completedAt;

  TaskCompletionResult({
    required this.taskCompletionId,
    required this.taskId,
    required this.screeningId,
    required this.completedAt,
  });
}

class TaskCompletionStateData {
  final TaskCompletionState state;
  final TaskCompletionResult? result;
  final String? errorMessage;

  TaskCompletionStateData({
    required this.state,
    this.result,
    this.errorMessage,
  });

  factory TaskCompletionStateData.initial() {
    return TaskCompletionStateData(
      state: TaskCompletionState.initial,
      result: null,
      errorMessage: null,
    );
  }
}

class TaskCompletionNotifier extends Notifier<TaskCompletionStateData> {
  @override
  TaskCompletionStateData build() {
    return TaskCompletionStateData.initial();
  }

  void startCompletion() {
    state = TaskCompletionStateData(
      state: TaskCompletionState.processing,
      result: null,
      errorMessage: null,
    );
  }

  void completeTask(TaskCompletionResult result) {
    state = TaskCompletionStateData(
      state: TaskCompletionState.complete,
      result: result,
      errorMessage: null,
    );
  }

  void setError(String errorMessage) {
    state = TaskCompletionStateData(
      state: TaskCompletionState.error,
      result: null,
      errorMessage: errorMessage,
    );
  }

  void reset() {
    state = TaskCompletionStateData.initial();
  }
}

final taskCompletionProvider =
    NotifierProvider<TaskCompletionNotifier, TaskCompletionStateData>(() {
      return TaskCompletionNotifier();
    });
