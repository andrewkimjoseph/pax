import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/payment_method/payment_method.dart';

// A class to hold the withdraw context with amount and selected payment method
class WithdrawContext {
  final int tokenId;
  final num balance;
  final num? amountToWithdraw;
  final WithdrawalMethod? selectedWithdrawalMethod;

  WithdrawContext({
    required this.tokenId,
    required this.balance,
    this.amountToWithdraw,
    this.selectedWithdrawalMethod,
  });

  // Create a copy with updated values
  WithdrawContext copyWith({
    int? tokenId,
    num? balance,
    num? amountToWithdraw,
    WithdrawalMethod? selectedWithdrawalMethod,
  }) {
    return WithdrawContext(
      tokenId: tokenId ?? this.tokenId,
      balance: balance ?? this.balance,
      amountToWithdraw: amountToWithdraw ?? this.amountToWithdraw,
      selectedWithdrawalMethod:
          selectedWithdrawalMethod ?? this.selectedWithdrawalMethod,
    );
  }
}

// The notifier to manage the state
class WithdrawContextNotifier extends Notifier<WithdrawContext?> {
  @override
  WithdrawContext? build() {
    // Initialize with null
    return null;
  }

  // Set the withdraw context
  void setWithdrawContext(int tokenId, num balance) {
    state = WithdrawContext(tokenId: tokenId, balance: balance);
  }

  // Set the amount to withdraw
  void setAmountToWithdraw(num amount) {
    if (state == null) return;

    state = state!.copyWith(amountToWithdraw: amount);
  }

  // Set the selected payment method
  void setSelectedPaymentMethod(WithdrawalMethod? method) {
    if (state == null) return;

    state = WithdrawContext(
      tokenId: state!.tokenId,
      balance: state!.balance,
      amountToWithdraw: state!.amountToWithdraw,
      selectedWithdrawalMethod: method,
    );
  }

  // Clear the state
  void clear() {
    state = null;
  }
}

// Create the provider
final withdrawContextProvider =
    NotifierProvider<WithdrawContextNotifier, WithdrawContext?>(
      () => WithdrawContextNotifier(),
    );
