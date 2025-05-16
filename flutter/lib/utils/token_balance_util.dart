import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pax/utils/currency_symbol.dart';

class TokenBalanceUtil {
  /// Maps token IDs to their corresponding currency names
  static final Map<int, String> _tokenToCurrency = {
    1: 'good_dollar',
    2: 'celo_dollar',
    3: 'tether_usd',
    4: 'usd_coin',
  };

  /// Maps currency names to their corresponding token IDs
  static final Map<String, int> _currencyToToken = {
    'good_dollar': 1,
    'celo_dollar': 2,
    'tether_usd': 3,
    'usd_coin': 4,
  };

  /// Returns the formatted balance with symbol for a given token ID from a balances map
  static String getFormattedBalance(Map<int, num> balances, int tokenId) {
    // Get the balance for the token, default to 0 if not found
    final balance = balances[tokenId] ?? 0;

    // Get the currency name for the token ID
    final currencyName = _tokenToCurrency[tokenId] ?? 'unknown';

    // Get the symbol for the currency
    final symbol = CurrencySymbolUtil.getSymbolForCurrency(currencyName);

    // Return formatted balance with symbol
    return '$symbol $balance';
  }

  /// Returns the raw balance for a given token ID from a balances map
  static num getBalance(Map<String, num>? balances, String tokenId) {
    return balances?[tokenId] ?? 0;
  }

  // Returns the raw balance for a given currency name from a balances map

  static num getBalanceByCurrency(
    Map<int, num>? balances,
    String currencyName, {
    bool formatAsInteger = false,
  }) {
    if (balances == null || currencyName.isEmpty) {
      return 0;
    }

    // Get the token ID for this currency (handle case insensitivity)
    final tokenId = _currencyToToken[currencyName.toLowerCase()];
    if (tokenId == null) {
      if (kDebugMode) {
        print('Warning: Unknown currency name: $currencyName');
      }
      return 0;
    }

    // Get the raw balance from the map
    final rawBalance = balances[tokenId] ?? 0;

    // If formatting is requested, format as integer with thousands separators
    if (formatAsInteger) {
      return rawBalance.toInt();
    }

    // Return the raw balance
    return rawBalance;
  }

  // Add a companion method for formatted output
  static String getFormattedBalanceByCurrency(
    Map<int, num>? balances,
    String currencyName, {
    bool includeSymbol = false,
    bool includeDecimals = false,
  }) {
    // Get the raw balance
    final rawBalance = getBalanceByCurrency(balances, currencyName);

    final locale = Intl.getCurrentLocale();

    // Create formatter based on whether to include decimals
    final NumberFormat formatter =
        includeDecimals
            ? NumberFormat('#,##0.00', locale)
            : NumberFormat('#,###', locale);

    // Format the number
    final formattedNumber = formatter.format(rawBalance);

    // Add symbol if requested
    if (includeSymbol) {
      final symbol = CurrencySymbolUtil.getSymbolForCurrency(currencyName);
      return '$symbol $formattedNumber';
    }

    return formattedNumber;
  }

  static String getLocaleFormattedAmount(num amount) {
    // Get the raw balance

    final locale = Intl.getCurrentLocale();

    // Create formatter based on whether to include decimals
    final NumberFormat formatter = NumberFormat('#,###.######', locale);

    // Format the number
    final formattedNumber = formatter.format(amount);

    // Add symbol if requested

    return formattedNumber;
  }

  /// Returns the symbol for a given token ID
  static String getSymbolForTokenId(int tokenId) {
    final currencyName = _tokenToCurrency[tokenId] ?? 'unknown';
    return CurrencySymbolUtil.getSymbolForCurrency(currencyName);
  }

  /// Returns the token ID for a given currency name
  static int? getTokenIdForCurrency(String currencyName) {
    return _currencyToToken[currencyName.toLowerCase()];
  }

  /// Gets all available balances formatted with their symbols
  static Map<int, String> getAllFormattedBalances(Map<int, num> balances) {
    final result = <int, String>{};

    balances.forEach((tokenId, amount) {
      final symbol = getSymbolForTokenId(tokenId);
      result[tokenId] = '$symbol $amount';
    });

    return result;
  }

  /// Checks if a user has sufficient balance for a token
  static bool hasSufficientBalance(
    Map<String, num> balances,
    String tokenId,
    num requiredAmount,
  ) {
    final balance = getBalance(balances, tokenId);
    return balance >= requiredAmount;
  }

  /// Checks if a user has sufficient balance for a currency
  static bool hasSufficientBalanceByCurrency(
    Map<int, num> balances,
    String currencyName,
    num requiredAmount,
  ) {
    final balance = getBalanceByCurrency(balances, currencyName);
    return balance >= requiredAmount;
  }
}
