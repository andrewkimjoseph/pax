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
  final int numberOfCooldownHours;
  final Timestamp? timeCompleted;
  final Timestamp? timeCreated;
  final bool? isValid;

  ClaimRewardContext({
    this.screeningId,
    this.taskId,
    this.taskCompletionId,
    this.amount,
    this.tokenId,
    this.txnHash,
    this.taskIsCompleted,
    this.numberOfCooldownHours = 0,
    this.timeCompleted,
    this.timeCreated,
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
    int? numberOfCooldownHours,
    Timestamp? timeCompleted,
    Timestamp? timeCreated,
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
      numberOfCooldownHours:
          numberOfCooldownHours ?? this.numberOfCooldownHours,
      timeCompleted: timeCompleted ?? this.timeCompleted,
      timeCreated: timeCreated ?? this.timeCreated,
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
    int numberOfCooldownHours = 0,
    Timestamp? timeCompleted,
    Timestamp? timeCreated,
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
      numberOfCooldownHours: numberOfCooldownHours,
      timeCompleted: timeCompleted,
      timeCreated: timeCreated,
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
