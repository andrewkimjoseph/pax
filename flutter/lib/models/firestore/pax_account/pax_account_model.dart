// models/pax_account/pax_account_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PaxAccount {
  final String id; // Same as participant ID
  final String? contractAddress;
  final String? contractCreationTxnHash;
  final Timestamp? timeCreated;
  final Timestamp? timeUpdated;
  final String? serverWalletId;
  final String? serverWalletAddress;
  final String? smartAccountWalletAddress;

  PaxAccount({
    required this.id,
    this.contractAddress,
    this.contractCreationTxnHash,
    this.timeCreated,
    this.timeUpdated,
    this.serverWalletId,
    this.serverWalletAddress,
    this.smartAccountWalletAddress,
  });

  // Create a copy with updates
  PaxAccount copyWith({
    String? contractAddress,
    String? contractCreationTxnHash,
    Timestamp? timeUpdated,
    String? serverWalletId,
    String? serverWalletAddress,
    String? smartAccountWalletAddress,
  }) {
    return PaxAccount(
      id: id,
      contractAddress: contractAddress ?? this.contractAddress,
      contractCreationTxnHash:
          contractCreationTxnHash ?? this.contractCreationTxnHash,
      timeCreated: timeCreated,
      timeUpdated: timeUpdated ?? this.timeUpdated,
      serverWalletId: serverWalletId ?? this.serverWalletId,
      serverWalletAddress: serverWalletAddress ?? this.serverWalletAddress,
      smartAccountWalletAddress:
          smartAccountWalletAddress ?? this.smartAccountWalletAddress,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contractAddress': contractAddress,
      'contractCreationTxnHash': contractCreationTxnHash,
      'timeCreated': timeCreated,
      'timeUpdated': timeUpdated,
      'serverWalletId': serverWalletId,
      'serverWalletAddress': serverWalletAddress,
      'smartAccountWalletAddress': smartAccountWalletAddress,
    };
  }

  // Create from Firestore data
  factory PaxAccount.fromMap(Map<String, dynamic> map, {required String id}) {
    return PaxAccount(
      id: id,
      contractAddress: map['contractAddress'],
      contractCreationTxnHash: map['contractCreationTxnHash'],
      timeCreated: map['timeCreated'],
      timeUpdated: map['timeUpdated'],
      serverWalletId: map['serverWalletId'],
      serverWalletAddress: map['serverWalletAddress'],
      smartAccountWalletAddress: map['smartAccountWalletAddress'],
    );
  }

  // Create empty account
  factory PaxAccount.empty() {
    return PaxAccount(id: '');
  }

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
