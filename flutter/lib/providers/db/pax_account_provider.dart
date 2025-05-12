// providers/db/pax_account_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/models/firestore/pax_account/pax_account_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/repositories/db/pax_account/pax_account_repository.dart';

// State for the pax account provider
enum PaxAccountState { initial, loading, loaded, error }

// Account state model
class PaxAccountStateModel {
  final PaxAccountModel? account;
  final PaxAccountState state;
  final String? errorMessage;

  PaxAccountStateModel({this.account, required this.state, this.errorMessage});

  // Initial state factory
  factory PaxAccountStateModel.initial() {
    return PaxAccountStateModel(state: PaxAccountState.initial);
  }

  // Copy with method
  PaxAccountStateModel copyWith({
    PaxAccountModel? account,
    PaxAccountState? state,
    String? errorMessage,
  }) {
    return PaxAccountStateModel(
      account: account ?? this.account,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Pax Account notifier
class PaxAccountNotifier extends StateNotifier<PaxAccountStateModel> {
  final PaxAccountRepository _repository;
  final Ref _ref;

  PaxAccountNotifier(this._repository, this._ref)
    : super(PaxAccountStateModel.initial()) {
    // Check initial auth state
    final authState = _ref.read(authProvider);

    // Automatically sync with auth state if user is authenticated
    if (authState.state == AuthState.authenticated) {
      syncWithAuthState(authState);
    }
  }

  // Sync account data with auth state
  Future<void> syncWithAuthState([AuthStateModel? authStateModel]) async {
    // Get auth state from provider if not provided
    final authState = authStateModel ?? _ref.read(authProvider);

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
    } catch (e) {
      // Handle error
      state = state.copyWith(
        state: PaxAccountState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Update balance for a token
  Future<void> updateBalance(String tokenId, num amount) async {
    final authState = _ref.read(authProvider);

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
    final authState = _ref.read(authProvider);

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

  // Refresh account data from Firestore
  Future<void> refreshAccount() async {
    final authState = _ref.read(authProvider);

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

// StateNotifierProvider for pax account state
final paxAccountProvider =
    StateNotifierProvider<PaxAccountNotifier, PaxAccountStateModel>((ref) {
      final repository = ref.watch(paxAccountRepositoryProvider);

      // Create the notifier
      final notifier = PaxAccountNotifier(repository, ref);

      // Set up auth state listener
      ref.listen(authProvider, (previous, next) {
        // When auth state changes
        if (previous?.state != next.state) {
          if (next.state == AuthState.authenticated) {
            // User just signed in, sync account data
            notifier.syncWithAuthState(next);
          } else if (next.state == AuthState.unauthenticated) {
            // User signed out, clear account data
            notifier.clearAccount();
          }
        }
      });

      return notifier;
    });
