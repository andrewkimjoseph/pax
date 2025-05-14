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
  final String? safeSmartAccountWalletId;
  final String? safeSmartAccountWalletAddress;
  final Map<String, num> balances;

  PaxAccount({
    required this.id,
    this.contractAddress,
    this.contractCreationTxnHash,
    this.timeCreated,
    this.timeUpdated,
    this.serverWalletId,
    this.serverWalletAddress,
    this.safeSmartAccountWalletId,
    this.safeSmartAccountWalletAddress,
    Map<String, num>? balances,
  }) : balances = balances ?? {'0': 0};

  // Create a copy with updates
  PaxAccount copyWith({
    String? contractAddress,
    String? contractCreationTxnHash,
    Timestamp? timeUpdated,
    String? serverWalletId,
    String? serverWalletAddress,
    String? safeSmartAccountWalletId,
    String? safeSmartAccountWalletAddress,
    Map<String, num>? balances,
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
      safeSmartAccountWalletId:
          safeSmartAccountWalletId ?? this.safeSmartAccountWalletId,
      safeSmartAccountWalletAddress:
          safeSmartAccountWalletAddress ?? this.safeSmartAccountWalletAddress,
      balances: balances ?? this.balances,
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
      'safeSmartAccountWalletId': safeSmartAccountWalletId,
      'safeSmartAccountWalletAddress': safeSmartAccountWalletAddress,
      'balances': balances,
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
      safeSmartAccountWalletId: map['safeSmartAccountWalletId'],
      safeSmartAccountWalletAddress: map['safeSmartAccountWalletAddress'],
      balances:
          map['balances'] != null
              ? Map<String, num>.from(map['balances'])
              : {'0': 0},
    );
  }

  // Create empty account
  factory PaxAccount.empty() {
    return PaxAccount(id: '', balances: {'0': 0});
  }

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
