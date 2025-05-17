// reward_currency_context_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A simple class to hold the reward currency context
class RewardCurrencyContext {
  final String selectedCurrency;

  RewardCurrencyContext({required this.selectedCurrency});

  // Create a copy with updated value
  RewardCurrencyContext copyWith({String? selectedCurrency}) {
    return RewardCurrencyContext(
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
    );
  }
}

// The notifier to manage the state
class RewardCurrencyContextNotifier extends Notifier<RewardCurrencyContext> {
  @override
  RewardCurrencyContext build() {
    // Initialize with default value
    return RewardCurrencyContext(selectedCurrency: 'good_dollar');
  }

  // Set the selected currency
  void setSelectedCurrency(String currency) {
    state = state.copyWith(selectedCurrency: currency);
  }

  // Reset to default
  void reset() {
    state = RewardCurrencyContext(selectedCurrency: 'good_dollar');
  }
}

// Create the provider
final rewardCurrencyContextProvider =
    NotifierProvider<RewardCurrencyContextNotifier, RewardCurrencyContext>(
      () => RewardCurrencyContextNotifier(),
    );
