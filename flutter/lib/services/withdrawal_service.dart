// This service manages the withdrawal process for participants:
// - Handles withdrawals to payment methods through Firebase Functions
// - Validates PaxAccount and server wallet information
// - Creates withdrawal records in Firestore
// - Provides methods to query withdrawal history
// - Includes comprehensive error handling and validation

// lib/services/withdrawal/withdrawal_service.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/withdrawal/withdrawal_model.dart';
import 'package:pax/repositories/firestore/pax_account/pax_account_repository.dart';
import 'package:pax/repositories/firestore/withdrawal/withdrawal_repository.dart';

class WithdrawalService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final PaxAccountRepository _paxAccountRepository;
  final WithdrawalRepository _withdrawalRepository;

  WithdrawalService({
    required PaxAccountRepository paxAccountRepository,
    required WithdrawalRepository withdrawalRepository,
  }) : _paxAccountRepository = paxAccountRepository,
       _withdrawalRepository = withdrawalRepository;

  /// Process a withdrawal to a payment method
  Future<Map<String, dynamic>> withdrawToPaymentMethod({
    required String userId,
    required String paymentMethodId,
    int predefinedId = 1,

    required double amountToWithdraw,
    required int tokenId,
    required String currencyAddress,
    int decimals = 18,
  }) async {
    try {
      // 1. Get PaxAccount for user
      final paxAccount = await _paxAccountRepository.getAccount(userId);
      if (paxAccount == null) {
        throw Exception('PaxAccount not found');
      }

      // 2. Validate server wallet and contract address
      final serverWalletId = paxAccount.serverWalletId;
      if (serverWalletId == null || serverWalletId.isEmpty) {
        throw Exception('Server wallet not found');
      }

      final paxAccountAddress = paxAccount.contractAddress;
      if (paxAccountAddress == null || paxAccountAddress.isEmpty) {
        throw Exception('Contract address not found');
      }

      // 3. Call the cloud function
      final callable = _functions.httpsCallable(
        'withdrawToPaymentMethod',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 300)),
      );

      final result = await callable.call({
        'serverWalletId': serverWalletId,
        'paxAccountAddress': paxAccountAddress,
        'paymentMethodId': predefinedId - 1,
        'amountRequested': amountToWithdraw,
        'currency': currencyAddress,
        'decimals': decimals,
      });

      Timestamp timeRequested = Timestamp.now();

      if (result.data == null) {
        throw Exception('Withdrawal failed - empty response');
      }

      // 4. Create withdrawal record in Firestore
      final withdrawal = Withdrawal(
        id: FirebaseFirestore.instance.collection('withdrawals').doc().id,
        participantId: userId,
        paymentMethodId: paymentMethodId,
        amountTakenOut: amountToWithdraw,
        rewardCurrencyId: tokenId,
        txnHash: result.data['txnHash'],
        timeCreated: Timestamp.now(),
        timeRequested: timeRequested,
        timeUpdated: Timestamp.now(),
      );

      await _withdrawalRepository.createWithdrawal(withdrawal);

      // 5. Return success data
      return {
        'success': true,
        'txnHash': result.data['txnHash'],
        'withdrawalId': withdrawal.id,
        'details': result.data['details'],
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error withdrawing tokens: $e');
      }
      throw Exception('Failed to withdraw tokens: ${e.toString()}');
    }
  }

  /// Get all withdrawals for a participant
  Future<List<Withdrawal>> getWithdrawalsForParticipant(String userId) async {
    return await _withdrawalRepository.getWithdrawalsForParticipant(userId);
  }

  /// Get a specific withdrawal by ID
  Future<Withdrawal?> getWithdrawal(String withdrawalId) async {
    return await _withdrawalRepository.getWithdrawal(withdrawalId);
  }
}
