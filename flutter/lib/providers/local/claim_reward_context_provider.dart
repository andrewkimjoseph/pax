import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClaimRewardContext {
  final String? screeningId;
  final String? taskId;
  final String? taskCompletionId;
  final num? amount;
  final int? tokenId;
  final String? txnHash;
  bool? taskIsCompleted = false;
  final int numberOfCooldownDays;
  final Timestamp? timeCompleted;
  final bool? isValid;

  ClaimRewardContext({
    this.screeningId,
    this.taskId,
    this.taskCompletionId,
    this.amount,
    this.tokenId,
    this.txnHash,
    this.taskIsCompleted,
    this.numberOfCooldownDays = 0,
    this.timeCompleted,
    this.isValid,
  });

  ClaimRewardContext copyWith({
    String? screeningId,
    String? taskId,
    String? taskCompletionId,
    num? amount,
    int? tokenId,
    String? txnHash,
    bool? taskIsCompleted,
    int? numberOfCooldownDays,
    Timestamp? timeCompleted,
    bool? isValid,
  }) {
    return ClaimRewardContext(
      screeningId: screeningId ?? this.screeningId,
      taskId: taskId ?? this.taskId,
      taskCompletionId: taskCompletionId ?? this.taskCompletionId,
      amount: amount ?? this.amount,
      tokenId: tokenId ?? this.tokenId,
      txnHash: txnHash ?? this.txnHash,
      taskIsCompleted: taskIsCompleted ?? this.taskIsCompleted,
      numberOfCooldownDays: numberOfCooldownDays ?? this.numberOfCooldownDays,
      timeCompleted: timeCompleted ?? this.timeCompleted,
      isValid: isValid ?? this.isValid,
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
    bool? taskIsCompleted,
    int numberOfCooldownDays = 0,
    Timestamp? timeCompleted,
    bool? isValid,
  }) {
    state = ClaimRewardContext(
      screeningId: screeningId,
      taskId: taskId,
      taskCompletionId: taskCompletionId,
      amount: amount,
      tokenId: tokenId,
      txnHash: txnHash,
      taskIsCompleted: taskIsCompleted,
      numberOfCooldownDays: numberOfCooldownDays,
      timeCompleted: timeCompleted,
      isValid: isValid,
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
