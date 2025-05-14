// lib/models/reward/reward_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  final String id;
  final String? participantId;
  final String? taskId;
  final String? screeningId;
  final String? taskCompletionId;
  final String? signature;
  final num? amountReceived;
  final int? rewardCurrencyId;
  final String? txnHash;
  final bool isPaidOutToPaxAccount;
  final Timestamp? timePaidOut;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;

  Reward({
    required this.id,
    this.participantId,
    this.taskId,
    this.screeningId,
    this.taskCompletionId,
    this.signature,
    this.amountReceived,
    this.rewardCurrencyId,
    this.txnHash,
    this.isPaidOutToPaxAccount = false,
    this.timePaidOut,
    this.timeCreated,
    this.timeUpdated,
  });

  factory Reward.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Reward data is null');
    }

    return Reward(
      id: doc.id,
      participantId: data['participantId'],
      taskId: data['taskId'],
      screeningId: data['screeningId'],
      taskCompletionId: data['taskCompletionId'],
      signature: data['signature'],
      amountReceived: data['amountReceived'],
      rewardCurrencyId: data['rewardCurrencyId'],
      txnHash: data['txnHash'],
      isPaidOutToPaxAccount: data['isPaidOutToPaxAccount'] ?? false,
      timePaidOut: data['timePaidOut'],
      timeCreated: data['timeCreated'],
      timeUpdated: data['timeUpdated'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'taskId': taskId,
      'screeningId': screeningId,
      'taskCompletionId': taskCompletionId,
      'signature': signature,
      'amountReceived': amountReceived,
      'rewardCurrencyId': rewardCurrencyId,
      'txnHash': txnHash,
      'isPaidOutToPaxAccount': isPaidOutToPaxAccount,
      'timePaidOut': timePaidOut,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
    };
  }
}
