// Note: This provider manages the state of payment methods, which are presented as
// "Withdrawal Methods" in the UI for better user experience. The underlying data
// structure and database collection remain as "payment_methods".
// providers/payment_method_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/models/firestore/payment_method/payment_method.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/repositories/firestore/payment_method/payment_method_repository.dart';

// State enum for payment methods
enum WithdrawalMethodsState { initial, loading, loaded, error }

// State model for payment methods
// providers/payment_method_provider.dart

// State model for payment methods
class WithdrawalMethodsStateModel {
  final List<WithdrawalMethod> withdrawalMethods;
  final WithdrawalMethodsState state;
  final String? errorMessage;
  final Timestamp? lastUpdated;

  WithdrawalMethodsStateModel({
    this.withdrawalMethods = const [],
    this.state = WithdrawalMethodsState.initial,
    this.errorMessage,
    this.lastUpdated,
  });

  // Check if there are any payment methods
  bool get hasWithdrawalMethods => withdrawalMethods.isNotEmpty;

  // Get payment method by ID
  WithdrawalMethod? getWithdrawalMethodById(String id) {
    try {
      return withdrawalMethods.firstWhere((method) => method.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get payment method by wallet address
  WithdrawalMethod? getWithdrawalMethodByWalletAddress(String walletAddress) {
    try {
      return withdrawalMethods.firstWhere(
        (method) => method.walletAddress == walletAddress,
      );
    } catch (_) {
      return null;
    }
  }

  // Get payment methods by type/name
  List<WithdrawalMethod> getWithdrawalMethodsByType(String name) {
    return withdrawalMethods.where((method) => method.name == name).toList();
  }

  // Get primary payment method (the first in the list)
  WithdrawalMethod? get primaryPaymentMethod {
    return withdrawalMethods.isNotEmpty ? withdrawalMethods.first : null;
  }

  // Copy with method
  WithdrawalMethodsStateModel copyWith({
    List<WithdrawalMethod>? withdrawalMethods,
    WithdrawalMethodsState? state,
    String? errorMessage,
    Timestamp? lastUpdated,
  }) {
    return WithdrawalMethodsStateModel(
      withdrawalMethods: withdrawalMethods ?? this.withdrawalMethods,
      state: state ?? this.state,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Payment Methods Notifier
class WithdrawalMethodsNotifier extends Notifier<WithdrawalMethodsStateModel> {
  late final WithdrawalMethodRepository _repository;

  @override
  WithdrawalMethodsStateModel build() {
    _repository = ref.watch(withdrawalMethodRepositoryProvider);

    // Set up auth state listener
    ref.listen(authProvider, (previous, next) {
      // When auth state changes
      if (previous?.state != next.state) {
        if (next.state == AuthState.authenticated) {
          // User just signed in, fetch payment methods
          fetchPaymentMethods(next.user.uid);
        } else if (next.state == AuthState.unauthenticated) {
          // User signed out, clear payment methods
          clearPaymentMethods();
        }
      }
    });

    // Check initial auth state
    final authState = ref.read(authProvider);

    // Automatically fetch payment methods if user is authenticated
    if (authState.state == AuthState.authenticated) {
      // We need to use Future.microtask because we can't use async in build
      Future.microtask(() => fetchPaymentMethods(authState.user.uid));
    }

    return WithdrawalMethodsStateModel();
  }

  // Fetch all payment methods for a user
  Future<void> fetchPaymentMethods(String userId) async {
    try {
      // Set loading state
      state = state.copyWith(state: WithdrawalMethodsState.loading);

      // Fetch payment methods from repository
      final methods = await _repository.getPaymentMethodsForParticipant(userId);

      // Sort payment methods (customize this based on your needs)
      methods.sort((a, b) {
        // Example: Sort by time created, most recent first
        if (a.timeCreated == null || b.timeCreated == null) {
          return 0;
        }
        return b.timeCreated!.compareTo(a.timeCreated!);
      });

      // Update state with fetched methods
      state = state.copyWith(
        withdrawalMethods: methods,
        state: WithdrawalMethodsState.loaded,
        lastUpdated: Timestamp.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching payment methods: $e');
      }
      // Update state with error
      state = state.copyWith(
        state: WithdrawalMethodsState.error,
        errorMessage: 'Failed to load payment methods: ${e.toString()}',
      );
    }
  }

  // Add a new payment method
  Future<bool> addPaymentMethod(WithdrawalMethod paymentMethod) async {
    try {
      // Set loading state
      state = state.copyWith(state: WithdrawalMethodsState.loading);

      // Add payment method to repository
      await _repository.createWithdrawalMethod(
        participantId: paymentMethod.participantId,
        paxAccountId: paymentMethod.paxAccountId,
        walletAddress: paymentMethod.walletAddress,
        name: paymentMethod.name,
        predefinedId: paymentMethod.predefinedId,
      );

      // Refresh payment methods
      await fetchPaymentMethods(paymentMethod.participantId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding payment method: $e');
      }
      // Update state with error
      state = state.copyWith(
        state: WithdrawalMethodsState.error,
        errorMessage: 'Failed to add payment method: ${e.toString()}',
      );
      return false;
    }
  }

  // Remove a payment method
  Future<bool> removePaymentMethod(
    String paymentMethodId,
    String userId,
  ) async {
    try {
      // Set loading state
      state = state.copyWith(state: WithdrawalMethodsState.loading);

      // Remove payment method from repository
      await _repository.deletePaymentMethod(paymentMethodId);

      // Refresh payment methods
      await fetchPaymentMethods(userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error removing payment method: $e');
      }
      // Update state with error
      state = state.copyWith(
        state: WithdrawalMethodsState.error,
        errorMessage: 'Failed to remove payment method: ${e.toString()}',
      );
      return false;
    }
  }

  // Set a payment method as default
  Future<bool> setDefaultPaymentMethod(
    String paymentMethodId,
    String userId,
  ) async {
    try {
      // Set loading state
      state = state.copyWith(state: WithdrawalMethodsState.loading);

      // Update the payment method in repository
      await _repository.updatePaymentMethod(paymentMethodId, {
        'isDefault': true,
      });

      // Refresh payment methods
      await fetchPaymentMethods(userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error setting default payment method: $e');
      }
      // Update state with error
      state = state.copyWith(
        state: WithdrawalMethodsState.error,
        errorMessage: 'Failed to set default payment method: ${e.toString()}',
      );
      return false;
    }
  }

  // Clear payment methods (used when signing out)
  void clearPaymentMethods() {
    state = state.copyWith(
      withdrawalMethods: [],
      state: WithdrawalMethodsState.initial,
      errorMessage: null,
    );
  }

  // Manual refresh
  Future<void> refresh(String userId) async {
    await fetchPaymentMethods(userId);
  }
}

// Provider for the payment method repository
final withdrawalMethodRepositoryProvider = Provider<WithdrawalMethodRepository>(
  (ref) {
    return WithdrawalMethodRepository();
  },
);

// NotifierProvider for payment methods state
final withdrawalMethodsProvider =
    NotifierProvider<WithdrawalMethodsNotifier, WithdrawalMethodsStateModel>(
      () {
        return WithdrawalMethodsNotifier();
      },
    );

// Provider to get a specific payment method by ID
final withdrawalMethodByIdProvider = Provider.family<WithdrawalMethod?, String>(
  (ref, id) {
    final methodsState = ref.watch(withdrawalMethodsProvider);
    return methodsState.getWithdrawalMethodById(id);
  },
);

// Provider to check if a wallet address is already used
final isWalletAddressUsedProvider = Provider.family<bool, String>((
  ref,
  walletAddress,
) {
  final methodsState = ref.watch(withdrawalMethodsProvider);
  return methodsState.getWithdrawalMethodByWalletAddress(walletAddress) != null;
});

// Provider to get all payment methods of a specific type
final paymentMethodsByTypeProvider =
    Provider.family<List<WithdrawalMethod>, String>((ref, type) {
      final methodsState = ref.watch(withdrawalMethodsProvider);
      return methodsState.getWithdrawalMethodsByType(type);
    });

// Provider to get default payment method
final primaryPaymentMethodProvider = Provider<WithdrawalMethod?>((ref) {
  final methodsState = ref.watch(withdrawalMethodsProvider);
  return methodsState.primaryPaymentMethod;
});
