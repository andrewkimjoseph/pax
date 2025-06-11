import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClaimRewardContext {
  final String? screeningId;
  final String? taskId;
  final String? taskCompletionId;
  final num? amount;
  final int? tokenId;
  final String? txnHash;

  ClaimRewardContext({
    this.screeningId,
    this.taskId,
    this.taskCompletionId,
    this.amount,
    this.tokenId,
    this.txnHash,
  });

  ClaimRewardContext copyWith({
    String? screeningId,
    String? taskId,
    String? taskCompletionId,
    num? amount,
    int? tokenId,
    String? txnHash,
  }) {
    return ClaimRewardContext(
      screeningId: screeningId ?? this.screeningId,
      taskId: taskId ?? this.taskId,
      taskCompletionId: taskCompletionId ?? this.taskCompletionId,
      amount: amount ?? this.amount,
      tokenId: tokenId ?? this.tokenId,
      txnHash: txnHash ?? this.txnHash,
    );
  }
}

class ClaimRewardContextNotifier extends Notifier<ClaimRewardContext?> {
  @override
  ClaimRewardContext? build() {
    return null;
  }

  void setContext({
    String? screeningId,
    String? taskId,
    String? taskCompletionId,
    num? amount,
    int? tokenId,
    String? txnHash,
  }) {
    state = ClaimRewardContext(
      screeningId: screeningId,
      taskId: taskId,
      taskCompletionId: taskCompletionId,
      amount: amount,
      tokenId: tokenId,
      txnHash: txnHash,
    );
  }

  void clear() {
    state = null;
  }
}

final claimRewardContextProvider =
    NotifierProvider<ClaimRewardContextNotifier, ClaimRewardContext?>(
      () => ClaimRewardContextNotifier(),
    );
