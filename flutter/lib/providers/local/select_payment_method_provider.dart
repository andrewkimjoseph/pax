import 'package:flutter_riverpod/flutter_riverpod.dart';

// Use NotifierProvider instead of StateProvider
class SelectedPaymentMethodNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null; // Initially no payment method is selected
  }

  void select(String id) {
    state = id;
  }

  void clear() {
    state = null;
  }
}

// Create the provider
final selectedPaymentMethodIdProvider =
    NotifierProvider<SelectedPaymentMethodNotifier, String?>(
      () => SelectedPaymentMethodNotifier(),
    );
