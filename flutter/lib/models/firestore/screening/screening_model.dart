// lib/models/screening/screening_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Screening {
  final String id;
  final String? taskId;
  final String? participantId;
  final String? signature;
  final String? nonce;
  final String? txnHash;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;

  Screening({
    required this.id,
    this.taskId,
    this.participantId,
    this.signature,
    this.nonce,
    this.txnHash,
    this.timeCreated,
    this.timeUpdated,
  });

  // Factory method to create a Screening from Firestore document
  factory Screening.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return Screening(id: doc.id);
    }

    return Screening(
      id: doc.id,
      taskId: data['taskId'],
      participantId: data['participantId'],
      signature: data['signature'],
      nonce: data['nonce'],
      txnHash: data['txnHash'],
      timeCreated: data['timeCreated'],
      timeUpdated: data['timeUpdated'],
    );
  }

  // Convert Screening to a Map
  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'participantId': participantId,
      'signature': signature,
      'nonce': nonce,
      'txnHash': txnHash,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
    };
  }

  // Helper method to check if the screening is completed
  bool isCompleted() {
    return txnHash != null && txnHash!.isNotEmpty;
  }

  // Helper method to check if the screening has a valid signature
  bool hasValidSignature() {
    return signature != null &&
        signature!.isNotEmpty &&
        nonce != null &&
        nonce!.isNotEmpty;
  }

  // Create a copy with updated values
  Screening copyWith({
    String? id,
    String? taskId,
    String? participantId,
    String? signature,
    String? nonce,
    String? txnHash,
    Timestamp? timeCreated,
    Timestamp? timeUpdated,
  }) {
    return Screening(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      participantId: participantId ?? this.participantId,
      signature: signature ?? this.signature,
      nonce: nonce ?? this.nonce,
      txnHash: txnHash ?? this.txnHash,
      timeCreated: timeCreated ?? this.timeCreated,
      timeUpdated: timeUpdated ?? this.timeUpdated,
    );
  }
}
