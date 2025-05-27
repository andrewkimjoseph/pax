// lib/providers/withdraw/withdraw_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/local/withdrawal_state_model.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/providers/local/withdrawal_service_provider.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/services/withdrawal_service.dart';
import 'package:pax/services/notifications/notification_service.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/models/firestore/withdrawal/withdrawal_model.dart';
import 'package:pax/services/blockchain/blockchain_service.dart';

class WithdrawNotifier extends Notifier<WithdrawStateModel> {
  late final WithdrawalService _withdrawalService;
  final NotificationService _notificationService = NotificationService();
  final BlockchainService _blockchainService = BlockchainService();

  @override
  WithdrawStateModel build() {
    _withdrawalService = ref.watch(withdrawalServiceProvider);
    return WithdrawStateModel();
  }

  Future<void> withdrawToPaymentMethod({
    required String paymentMethodId,
    required double amountToWithdraw,
    required int tokenId,
    required String currencyAddress,
    int decimals = 18,
  }) async {
    if (state.isSubmitting) return; // Prevent multiple submissions

    state = state.copyWith(
      state: WithdrawState.submitting,
      isSubmitting: true,
      errorMessage: null,
    );

    try {
      final auth = ref.read(authProvider);
      final userId = auth.user.uid;
      final paxAccountState = ref.read(paxAccountProvider);
      final paxAccount = paxAccountState.account;

      if (kDebugMode) {
        print(
          'Withdrawing: $amountToWithdraw tokens to payment method $paymentMethodId',
        );
        print(
          'Using currency address: $currencyAddress with $decimals decimals',
        );
      }

      // Check if contract has sufficient balance
      if (paxAccount?.contractAddress == null) {
        throw Exception('Contract address not found');
      }

      final hasBalance = await _blockchainService.hasSufficientBalance(
        paxAccount!.contractAddress!,
        currencyAddress,
        amountToWithdraw,
        decimals,
      );

      if (!hasBalance) {
        throw Exception('Insufficient contract balance for withdrawal');
      }

      // Call the withdrawal service
      final result = await _withdrawalService.withdrawToPaymentMethod(
        userId: userId,
        paymentMethodId: paymentMethodId,
        amountToWithdraw: amountToWithdraw,
        tokenId: tokenId,
        currencyAddress: currencyAddress,
        decimals: decimals,
      );

      if (kDebugMode) {
        print('Withdrawal transaction successful: ${result['txnHash']}');
      }

      // Update state to success
      state = state.copyWith(
        state: WithdrawState.success,
        isSubmitting: false,
        txnHash: result['txnHash'],
        withdrawalId: result['withdrawalId'],
      );

      ref.read(analyticsProvider).withdrawalComplete({
        "amount": amountToWithdraw,
        "tokenId": tokenId,
        "selectedPaymentMethodId": paymentMethodId,
        "contractAddress": paxAccount.contractAddress,
        "currencyAddress": currencyAddress,
      });

      // Send notification about successful withdrawal
      final fcmToken = await ref.read(fcmTokenProvider.future);
      if (fcmToken != null) {
        final currencyName = CurrencySymbolUtil.getNameForCurrency(tokenId);
        final currencySymbol = CurrencySymbolUtil.getSymbolForCurrency(
          currencyName,
        );

        await _notificationService.sendWithdrawalSuccessNotification(
          token: fcmToken,
          withdrawalData: {
            'amount': amountToWithdraw,
            'currencySymbol': currencySymbol,
            'txnHash': result['txnHash'],
          },
        );
      }

      // Refresh activities to show the new withdrawal
      ref.invalidate(activityRepositoryProvider);
      await ref.read(paxAccountProvider.notifier).syncBalancesFromBlockchain();
    } catch (e) {
      if (kDebugMode) {
        print('Error withdrawing tokens: $e');
      }

      state = state.copyWith(
        state: WithdrawState.error,
        errorMessage: e.toString(),
        isSubmitting: false,
      );
    }
  }

  void resetState() {
    state = WithdrawStateModel();
  }
}

final withdrawProvider = NotifierProvider<WithdrawNotifier, WithdrawStateModel>(
  () {
    return WithdrawNotifier();
  },
);

// Stream provider for withdrawals
final withdrawalsStreamProvider = StreamProvider.family<
  List<Withdrawal>,
  String?
>((ref, participantId) {
  // Use the withdrawal repository to get the stream of withdrawals for the participant
  final withdrawalRepository = ref.watch(withdrawalRepositoryProvider);
  return withdrawalRepository.streamWithdrawalsForParticipant(participantId);
});
