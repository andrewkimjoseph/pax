// lib/models/withdrawal/withdrawal_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Withdrawal {
  final String id;
  final String? participantId;
  final String? paymentMethodId;
  final num? amountTakenOut;
  final int? rewardCurrencyId;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;

  Withdrawal({
    required this.id,
    this.participantId,
    this.paymentMethodId,
    this.amountTakenOut,
    this.rewardCurrencyId,
    this.timeCreated,
    this.timeUpdated,
  });

  factory Withdrawal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Withdrawal data is null');
    }

    return Withdrawal(
      id: doc.id,
      participantId: data['participantId'],
      paymentMethodId: data['paymentMethodId'],
      amountTakenOut: data['amountRequested'],
      rewardCurrencyId: data['rewardCurrencyId'],
      timeCreated: data['timeCreated'],
      timeUpdated: data['timeUpdated'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'paymentMethodId': paymentMethodId,
      'amountRequested': amountTakenOut,
      'rewardCurrencyId': rewardCurrencyId,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
    };
  }
}
