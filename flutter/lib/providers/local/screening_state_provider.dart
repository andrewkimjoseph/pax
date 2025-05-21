// lib/providers/local/screening_state_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model for screening state
class ScreeningStateModel {
  final ScreeningState state;
  final String? errorMessage;
  final ScreeningResult? result;

  ScreeningStateModel({
    this.state = ScreeningState.initial,
    this.errorMessage,
    this.result,
  });

  ScreeningStateModel copyWith({
    ScreeningState? state,
    String? errorMessage,
    ScreeningResult? result,
  }) {
    return ScreeningStateModel(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
    );
  }
}

enum ScreeningState { initial, loading, complete, error }

// Screening result model to store the data returned from the function
class ScreeningResult {
  final String participantProxy;
  final String taskId;
  final String signature;
  final String nonce;
  final String txnHash;
  final String screeningId;
  final String taskCompletionId;

  ScreeningResult({
    required this.participantProxy,
    required this.taskId,
    required this.signature,
    required this.nonce,
    required this.txnHash,
    required this.screeningId,
    required this.taskCompletionId,
  });
}

// Notifier for screening state using modern Riverpod Notifier
class ScreeningNotifier extends Notifier<ScreeningStateModel> {
  @override
  ScreeningStateModel build() {
    return ScreeningStateModel();
  }

  void startScreening() {
    state = state.copyWith(state: ScreeningState.loading, errorMessage: null);
  }

  void completeScreening(ScreeningResult result) {
    state = state.copyWith(state: ScreeningState.complete, result: result);
  }

  void setError(String? errorMessage) {
    state = state.copyWith(
      state: ScreeningState.error,
      errorMessage: errorMessage ?? 'An unknown error occurred',
    );
  }

  void reset() {
    state = ScreeningStateModel();
  }
}

final screeningProvider =
    NotifierProvider<ScreeningNotifier, ScreeningStateModel>(
      () => ScreeningNotifier(),
    );
