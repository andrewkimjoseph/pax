// providers/db/pax_account_provider.dart - Updated with balance sync
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/models/firestore/pax_account/pax_account_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/repositories/firestore/pax_account/pax_account_repository.dart';
import 'package:pax/services/blockchain/blockchain_service.dart';

// State for the pax account provider
enum PaxAccountState {
  initial,
  loading,
  loaded,
  syncing, // New state for blockchain sync
  error,
}

// Account state model
class PaxAccountStateModel {
  final PaxAccount? account;
  final PaxAccountState state;
  final String? errorMessage;
  final bool
  isBalanceSynced; // Flag to indicate if balances are synced from blockchain

  PaxAccountStateModel({
    this.account,
    required this.state,
    this.errorMessage,
    this.isBalanceSynced = false,
  });

  // Initial state factory
  factory PaxAccountStateModel.initial() {
    return PaxAccountStateModel(state: PaxAccountState.initial);
  }

  // Copy with method
  PaxAccountStateModel copyWith({
    PaxAccount? account,
    PaxAccountState? state,
    String? errorMessage,
    bool? isBalanceSynced,
  }) {
    return PaxAccountStateModel(
      account: account ?? this.account,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      isBalanceSynced: isBalanceSynced ?? this.isBalanceSynced,
    );
  }
}

// Pax Account notifier with new Notifier syntax
class PaxAccountNotifier extends Notifier<PaxAccountStateModel> {
  late final PaxAccountRepository _repository;

  @override
  PaxAccountStateModel build() {
    _repository = ref.watch(paxAccountRepositoryProvider);

    // Set up auth state listener
    ref.listen(authProvider, (previous, next) {
      // When auth state changes
      if (previous?.state != next.state) {
        if (next.state == AuthState.authenticated) {
          // User just signed in, sync account data
          syncWithAuthState(next);
        } else if (next.state == AuthState.unauthenticated) {
          // User signed out, clear account data
          clearAccount();
        }
      }
    });

    // Check initial auth state
    final authState = ref.read(authProvider);

    // Automatically sync with auth state if user is authenticated
    if (authState.state == AuthState.authenticated) {
      // We need to use Future.microtask because we can't use async in build
      Future.microtask(() => syncWithAuthState(authState));
    }

    return PaxAccountStateModel.initial();
  }

  // Sync account data with auth state
  Future<void> syncWithAuthState([AuthStateModel? authStateModel]) async {
    // Get auth state from provider if not provided
    final authState = authStateModel ?? ref.read(authProvider);

    // Skip if not authenticated
    if (authState?.state != AuthState.authenticated) {
      state = PaxAccountStateModel.initial();
      return;
    }

    try {
      // Set loading state
      state = state.copyWith(state: PaxAccountState.loading);

      // Handle signup - create or get account
      final account = await _repository.handleUserSignup(authState!.user.uid);

      // Update state with loaded account
      state = state.copyWith(account: account, state: PaxAccountState.loaded);

      // Try to fetch balances from blockchain if contract address exists
      if (account.contractAddress != null &&
          account.contractAddress!.isNotEmpty) {
        // Don't await this to avoid blocking the UI
        syncBalancesFromBlockchain();
      }
    } catch (e) {
      // Handle error
      state = state.copyWith(
        state: PaxAccountState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Update balance for a token
  Future<void> updateBalance(int tokenId, num amount) async {
    final authState = ref.read(authProvider);

    try {
      // Ensure user is authenticated and we have an account
      if (authState.state != AuthState.authenticated || state.account == null) {
        throw Exception('User must be authenticated to update balance');
      }

      // Set loading state
      state = state.copyWith(state: PaxAccountState.loading);

      // Update balance in repository
      final updatedAccount = await _repository.updateBalance(
        authState.user.uid,
        tokenId,
        amount,
      );

      // Update state with updated account
      state = state.copyWith(
        account: updatedAccount,
        state: PaxAccountState.loaded,
      );
    } catch (e) {
      // Handle error
      state = state.copyWith(
        state: PaxAccountState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Update account fields
  Future<void> updateAccount(Map<String, dynamic> data) async {
    final authState = ref.read(authProvider);

    try {
      // Ensure user is authenticated and we have an account
      if (authState.state != AuthState.authenticated || state.account == null) {
        throw Exception('User must be authenticated to update account');
      }

      // Set loading state
      state = state.copyWith(state: PaxAccountState.loading);

      // Update account in repository
      final updatedAccount = await _repository.updateAccount(
        authState.user.uid,
        data,
      );

      // Update state with updated account
      state = state.copyWith(
        account: updatedAccount,
        state: PaxAccountState.loaded,
      );
    } catch (e) {
      // Handle error
      state = state.copyWith(
        state: PaxAccountState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Fetch and sync balances from blockchain
  Future<void> syncBalancesFromBlockchain() async {
    final authState = ref.read(authProvider);

    try {
      // Ensure user is authenticated and we have an account
      if (authState.state != AuthState.authenticated || state.account == null) {
        throw Exception('User must be authenticated to sync balances');
      }

      // Set syncing state
      state = state.copyWith(state: PaxAccountState.syncing);

      // Sync balances in repository
      final updatedAccount = await _repository.syncBalancesFromBlockchain(
        authState.user.uid,
      );

      // Update state with updated account
      state = state.copyWith(
        account: updatedAccount,
        state: PaxAccountState.loaded,
        isBalanceSynced: true,
      );
    } catch (e) {
      // Handle error
      state = state.copyWith(
        state: PaxAccountState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Fetch a specific token balance from blockchain (doesn't update Firestore)
  Future<double> fetchTokenBalance(int tokenId) async {
    final authState = ref.read(authProvider);

    try {
      // Ensure user is authenticated and we have an account
      if (authState.state != AuthState.authenticated || state.account == null) {
        throw Exception('User must be authenticated to fetch token balance');
      }

      // Fetch token balance from repository
      return await _repository.fetchTokenBalance(authState.user.uid, tokenId);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching token balance: $e');
      }
      return 0.0;
    }
  }

  // Get formatted balance for a token
  String getFormattedBalance(int tokenId) {
    if (state.account == null) {
      return BlockchainService.formatBalance(0, tokenId);
    }

    final balance = state.account!.balances[tokenId]?.toDouble() ?? 0.0;
    return BlockchainService.formatBalance(balance, tokenId);
  }

  // Refresh account data from Firestore
  Future<void> refreshAccount() async {
    final authState = ref.read(authProvider);

    try {
      // Ensure user is authenticated
      if (authState.state != AuthState.authenticated) {
        throw Exception('User must be authenticated to refresh account');
      }

      // Set loading state
      state = state.copyWith(state: PaxAccountState.loading);

      // Get account from repository
      final account = await _repository.getAccount(authState.user.uid);

      if (account != null) {
        // Update state with refreshed account
        state = state.copyWith(account: account, state: PaxAccountState.loaded);
      } else {
        // Account not found, create a new one
        await syncWithAuthState();
      }
    } catch (e) {
      // Handle error
      state = state.copyWith(
        state: PaxAccountState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Clear account data (used when signing out)
  void clearAccount() {
    state = PaxAccountStateModel.initial();
  }
}

// Provider for the pax account repository
final paxAccountRepositoryProvider = Provider<PaxAccountRepository>((ref) {
  return PaxAccountRepository();
});

// NotifierProvider for pax account state
final paxAccountProvider =
    NotifierProvider<PaxAccountNotifier, PaxAccountStateModel>(() {
      return PaxAccountNotifier();
    });

// Provider for blockchain service
final blockchainServiceProvider = Provider<BlockchainService>((ref) {
  return BlockchainService();
});
