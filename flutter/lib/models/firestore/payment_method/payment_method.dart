import 'package:cloud_firestore/cloud_firestore.dart';

// Note: While the UI refers to these as "Withdrawal Methods" for better user experience,
// the database stores them as "payment_methods". This class bridges that gap by providing
// a WithdrawalMethod model that maps to the payment_methods collection.

class WithdrawalMethod {
  final String id;
  final int predefinedId;
  final String participantId;
  final String paxAccountId;
  final String name;
  final String? txnHash;
  final String walletAddress;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;

  WithdrawalMethod({
    required this.id,
    required this.predefinedId,
    required this.participantId,
    required this.paxAccountId,
    required this.name,
    required this.walletAddress,
    this.txnHash,
    this.timeCreated,
    this.timeUpdated,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'predefinedId': predefinedId,
      'participantId': participantId,
      'paxAccountId': paxAccountId,
      'name': name,
      'walletAddress': walletAddress,
      'txnHash': txnHash,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
    };
  }

  // Create from Firestore data
  factory WithdrawalMethod.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return WithdrawalMethod(
      id: id,
      predefinedId: map['predefinedId'] ?? -1,
      participantId: map['participantId'] ?? '',
      paxAccountId: map['paxAccountId'] ?? '',
      name: map['name'] ?? '',
      walletAddress: map['walletAddress'] ?? '',
      txnHash: map['txnHash'],
      timeCreated: map['timeCreated'],
      timeUpdated: map['timeUpdated'],
    );
  }
}
