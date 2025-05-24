import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethod {
  final String id;
  final int predefinedId;
  final String participantId;
  final String paxAccountId;
  final String name;
  final String walletAddress;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;

  PaymentMethod({
    required this.id,
    this.predefinedId = 1,
    required this.participantId,
    required this.paxAccountId,
    this.name = 'MiniPay',
    required this.walletAddress,
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
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
    };
  }

  // Create from Firestore data
  factory PaymentMethod.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return PaymentMethod(
      id: id,
      predefinedId: map['predefinedId'] ?? 1,
      participantId: map['participantId'] ?? '',
      paxAccountId: map['paxAccountId'] ?? '',
      name: map['name'] ?? 'minipay',
      walletAddress: map['walletAddress'] ?? '',
      timeCreated: map['timeCreated'],
      timeUpdated: map['timeUpdated'],
    );
  }
}
