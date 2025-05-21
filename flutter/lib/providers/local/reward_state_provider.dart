// lib/providers/local/reward_state_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RewardState { initial, rewarding, complete, error }

class RewardResult {
  final String rewardId;
  final String taskId;
  final String participantId;
  final String taskCompletionId;
  final double amount;
  final int rewardCurrencyId;
  final String txnHash;

  RewardResult({
    required this.rewardId,
    required this.taskId,
    required this.participantId,
    required this.taskCompletionId,
    required this.amount,
    required this.rewardCurrencyId,
    required this.txnHash,
  });

  factory RewardResult.fromMap(Map<String, dynamic> data) {
    return RewardResult(
      rewardId: data['rewardRecordId'],
      taskId: data['taskId'],
      participantId: data['participantId'],
      taskCompletionId: data['taskCompletionId'],
      amount:
          (data['amount'] is int)
              ? (data['amount'] as int).toDouble()
              : (data['amount'] as double),
      rewardCurrencyId: data['rewardCurrencyId'],
      txnHash: data['txnHash'],
    );
  }
}

class RewardStateData {
  final RewardState state;
  final RewardResult? result;
  final String? errorMessage;

  RewardStateData({required this.state, this.result, this.errorMessage});

  factory RewardStateData.initial() {
    return RewardStateData(
      state: RewardState.initial,
      result: null,
      errorMessage: null,
    );
  }
}

class RewardStateNotifier extends Notifier<RewardStateData> {
  @override
  RewardStateData build() {
    return RewardStateData.initial();
  }

  void startRewarding() {
    state = RewardStateData(
      state: RewardState.rewarding,
      result: null,
      errorMessage: null,
    );
  }

  void completeRewarding(RewardResult result) {
    state = RewardStateData(
      state: RewardState.complete,
      result: result,
      errorMessage: null,
    );
  }

  void setError(String errorMessage) {
    state = RewardStateData(
      state: RewardState.error,
      result: null,
      errorMessage: errorMessage,
    );
  }

  void reset() {
    state = RewardStateData.initial();
  }
}

final rewardStateProvider =
    NotifierProvider<RewardStateNotifier, RewardStateData>(() {
      return RewardStateNotifier();
    });
