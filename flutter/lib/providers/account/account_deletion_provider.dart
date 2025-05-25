import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';

// Define an enum for the deletion state
enum AccountDeletionState { initial, checkingBalance, deleting, success, error }

// Define a state class for account deletion
class AccountDeletionStateModel {
  final AccountDeletionState state;
  final String? errorMessage;
  final bool isDeleting;

  AccountDeletionStateModel({
    this.state = AccountDeletionState.initial,
    this.errorMessage,
    this.isDeleting = false,
  });

  // Copy with method
  AccountDeletionStateModel copyWith({
    AccountDeletionState? state,
    String? errorMessage,
    bool? isDeleting,
  }) {
    return AccountDeletionStateModel(
      state: state ?? this.state,
      errorMessage: errorMessage,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

// Create a notifier for account deletion
class AccountDeletionNotifier extends Notifier<AccountDeletionStateModel> {
  @override
  AccountDeletionStateModel build() {
    return AccountDeletionStateModel();
  }

  // Delete account
  Future<void> deleteAccount() async {
    if (state.isDeleting) return; // Prevent multiple deletion attempts

    // Reset state
    state = AccountDeletionStateModel(
      state: AccountDeletionState.checkingBalance,
      isDeleting: true,
    );

    try {
      // Add a delay to show the checking balance state
      await Future.delayed(const Duration(seconds: 1));

      // Get the current PaxAccount
      final paxAccount = ref.read(paxAccountProvider).account;

      if (paxAccount != null) {
        // Check if any balance is non-zero
        bool hasNonZeroBalance = paxAccount.balances.values.any(
          (balance) => balance > 0,
        );

        if (hasNonZeroBalance) {
          state = state.copyWith(
            state: AccountDeletionState.error,
            errorMessage:
                "Please withdraw all funds first before deleting your account.",
            isDeleting: false,
          );
          return;
        }
      }

      // Start deletion process
      state = state.copyWith(state: AccountDeletionState.deleting);

      // Add a delay to show the deleting state
      await Future.delayed(const Duration(seconds: 1));

      // Call the delete participant function
      final functions = FirebaseFunctions.instance;
      await functions.httpsCallable('deleteParticipantOnRequest').call();

      // Add a delay before signing out
      await Future.delayed(const Duration(seconds: 1));

      // Force refresh auth state
      await ref.read(authProvider.notifier).signOut();

      // Set success state
      state = state.copyWith(
        state: AccountDeletionState.success,
        isDeleting: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
      state = state.copyWith(
        state: AccountDeletionState.error,
        errorMessage: "Failed to delete account. Please try again later.",
        isDeleting: false,
      );
    }
  }

  // Reset state
  void resetState() {
    state = AccountDeletionStateModel();
  }
}

// Create the provider for the account deletion notifier
final accountDeletionProvider =
    NotifierProvider<AccountDeletionNotifier, AccountDeletionStateModel>(() {
      return AccountDeletionNotifier();
    });
