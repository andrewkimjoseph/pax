// providers/payment_method_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/auth/auth_state_model.dart';
import 'package:pax/models/firestore/payment_method/payment_method.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/repositories/firestore/payment_method/payment_method_repository.dart';

// State enum for payment methods
enum PaymentMethodsState { initial, loading, loaded, error }

// State model for payment methods
// providers/payment_method_provider.dart

// State model for payment methods
class PaymentMethodsStateModel {
  final List<PaymentMethod> paymentMethods;
  final PaymentMethodsState state;
  final String? errorMessage;
  final Timestamp? lastUpdated;

  PaymentMethodsStateModel({
    this.paymentMethods = const [],
    this.state = PaymentMethodsState.initial,
    this.errorMessage,
    this.lastUpdated,
  });

  // Check if there are any payment methods
  bool get hasPaymentMethods => paymentMethods.isNotEmpty;

  // Get payment method by ID
  PaymentMethod? getPaymentMethodById(String id) {
    try {
      return paymentMethods.firstWhere((method) => method.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get payment method by wallet address
  PaymentMethod? getPaymentMethodByWalletAddress(String walletAddress) {
    try {
      return paymentMethods.firstWhere(
        (method) => method.walletAddress == walletAddress,
      );
    } catch (_) {
      return null;
    }
  }

  // Get payment methods by type/name
  List<PaymentMethod> getPaymentMethodsByType(String name) {
    return paymentMethods.where((method) => method.name == name).toList();
  }

  // Get primary payment method (the first in the list)
  PaymentMethod? get primaryPaymentMethod {
    return paymentMethods.isNotEmpty ? paymentMethods.first : null;
  }

  // Copy with method
  PaymentMethodsStateModel copyWith({
    List<PaymentMethod>? paymentMethods,
    PaymentMethodsState? state,
    String? errorMessage,
    Timestamp? lastUpdated,
  }) {
    return PaymentMethodsStateModel(
      paymentMethods: paymentMethods ?? this.paymentMethods,
      state: state ?? this.state,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Payment Methods Notifier
class PaymentMethodsNotifier extends Notifier<PaymentMethodsStateModel> {
  late final PaymentMethodRepository _repository;

  @override
  PaymentMethodsStateModel build() {
    _repository = ref.watch(paymentMethodRepositoryProvider);

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

    return PaymentMethodsStateModel();
  }

  // Fetch all payment methods for a user
  Future<void> fetchPaymentMethods(String userId) async {
    try {
      // Set loading state
      state = state.copyWith(state: PaymentMethodsState.loading);

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
        paymentMethods: methods,
        state: PaymentMethodsState.loaded,
        lastUpdated: Timestamp.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching payment methods: $e');
      }
      // Update state with error
      state = state.copyWith(
        state: PaymentMethodsState.error,
        errorMessage: 'Failed to load payment methods: ${e.toString()}',
      );
    }
  }

  // Add a new payment method
  Future<bool> addPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      // Set loading state
      state = state.copyWith(state: PaymentMethodsState.loading);

      // Add payment method to repository
      await _repository.createPaymentMethod(
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
        state: PaymentMethodsState.error,
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
      state = state.copyWith(state: PaymentMethodsState.loading);

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
        state: PaymentMethodsState.error,
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
      state = state.copyWith(state: PaymentMethodsState.loading);

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
        state: PaymentMethodsState.error,
        errorMessage: 'Failed to set default payment method: ${e.toString()}',
      );
      return false;
    }
  }

  // Clear payment methods (used when signing out)
  void clearPaymentMethods() {
    state = state.copyWith(
      paymentMethods: [],
      state: PaymentMethodsState.initial,
      errorMessage: null,
    );
  }

  // Manual refresh
  Future<void> refresh(String userId) async {
    await fetchPaymentMethods(userId);
  }
}

// Provider for the payment method repository
final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((
  ref,
) {
  return PaymentMethodRepository();
});

// NotifierProvider for payment methods state
final paymentMethodsProvider =
    NotifierProvider<PaymentMethodsNotifier, PaymentMethodsStateModel>(() {
      return PaymentMethodsNotifier();
    });

// Provider to get a specific payment method by ID
final paymentMethodByIdProvider = Provider.family<PaymentMethod?, String>((
  ref,
  id,
) {
  final methodsState = ref.watch(paymentMethodsProvider);
  return methodsState.getPaymentMethodById(id);
});

// Provider to check if a wallet address is already used
final isWalletAddressUsedProvider = Provider.family<bool, String>((
  ref,
  walletAddress,
) {
  final methodsState = ref.watch(paymentMethodsProvider);
  return methodsState.getPaymentMethodByWalletAddress(walletAddress) != null;
});

// Provider to get all payment methods of a specific type
final paymentMethodsByTypeProvider =
    Provider.family<List<PaymentMethod>, String>((ref, type) {
      final methodsState = ref.watch(paymentMethodsProvider);
      return methodsState.getPaymentMethodsByType(type);
    });

// Provider to get default payment method
final primaryPaymentMethodProvider = Provider<PaymentMethod?>((ref) {
  final methodsState = ref.watch(paymentMethodsProvider);
  return methodsState.primaryPaymentMethod;
});
