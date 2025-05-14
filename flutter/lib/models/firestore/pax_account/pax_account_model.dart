// models/pax_account/pax_account_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
  final Map<int, num> balances; // Keeping original type

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
    Map<int, num>? balances,
  }) : balances = balances ?? {0: 0};

  // Create a copy with updates
  PaxAccount copyWith({
    String? contractAddress,
    String? contractCreationTxnHash,
    Timestamp? timeUpdated,
    String? serverWalletId,
    String? serverWalletAddress,
    String? safeSmartAccountWalletId,
    String? safeSmartAccountWalletAddress,
    Map<int, num>? balances,
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
    // Convert int keys to string keys for Firestore compatibility
    final Map<String, num> balancesForFirestore = {};
    balances.forEach((key, value) {
      balancesForFirestore[key.toString()] = value;
    });

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
      'balances': balancesForFirestore, // Store with string keys
    };
  }

  // Create from Firestore data
  factory PaxAccount.fromMap(Map<String, dynamic> map, {required String id}) {
    // Convert string keys to int keys
    Map<int, num> parsedBalances = {};

    if (map['balances'] != null) {
      // Handle the map coming from Firestore
      final firestoreBalances = map['balances'] as Map<String, dynamic>;
      firestoreBalances.forEach((key, value) {
        try {
          // Convert key from string to int
          final intKey = int.parse(key);
          // Ensure value is num
          final numValue = value is num ? value : 0;
          parsedBalances[intKey] = numValue;
        } catch (e) {
          // Handle parsing errors (e.g., if key can't be parsed to int)
          if (kDebugMode) {
            print('Error parsing balance key "$key": $e');
          }
        }
      });
    }

    // If no balances found or all parsing failed, use default
    if (parsedBalances.isEmpty) {
      parsedBalances = {0: 0};
    }

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
      balances: parsedBalances, // Use the converted map with int keys
    );
  }

  // Create empty account
  factory PaxAccount.empty() {
    return PaxAccount(id: '', balances: {0: 0});
  }

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
