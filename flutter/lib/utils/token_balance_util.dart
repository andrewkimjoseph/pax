import 'package:pax/utils/currency_symbol.dart';

class TokenBalanceUtil {
  /// Maps token IDs to their corresponding currency names
  static Map<String, String> _tokenToCurrency = {
    '1': 'good_dollar',
    '2': 'celo_dollar',
    '3': 'tether_usd',
    '4': 'usd_coin',
  };

  /// Maps currency names to their corresponding token IDs
  static Map<String, String> _currencyToToken = {
    'good_dollar': '1',
    'celo_dollar': '2',
    'tether_usd': '3',
    'usd_coin': '4',
  };

  /// Returns the formatted balance with symbol for a given token ID from a balances map
  static String getFormattedBalance(Map<String, num> balances, String tokenId) {
    // Get the balance for the token, default to 0 if not found
    final balance = balances[tokenId] ?? 0;

    // Get the currency name for the token ID
    final currencyName = _tokenToCurrency[tokenId] ?? 'unknown';

    // Get the symbol for the currency
    final symbol = CurrencySymbolUtil.getSymbolForCurrency(currencyName);

    // Return formatted balance with symbol
    return '$symbol $balance';
  }

  /// Returns the formatted balance with symbol for a given currency name from a balances map
  static String getFormattedBalanceByCurrency(
    Map<String, num> balances,
    String currencyName,
  ) {
    // Get the token ID for this currency
    final tokenId = _currencyToToken[currencyName.toLowerCase()];
    if (tokenId == null) {
      return '${CurrencySymbolUtil.getSymbolForCurrency(currencyName)} 0';
    }

    // Get the balance and format it
    return getFormattedBalance(balances, tokenId);
  }

  /// Returns the raw balance for a given token ID from a balances map
  static num getBalance(Map<String, num>? balances, String tokenId) {
    return balances?[tokenId] ?? 0;
  }

  /// Returns the raw balance for a given currency name from a balances map
  static num getBalanceByCurrency(
    Map<String, num>? balances,
    String currencyName,
  ) {
    // Get the token ID for this currency
    final tokenId = _currencyToToken[currencyName.toLowerCase()];
    if (tokenId == null) {
      return 0;
    }

    // Return the balance
    return getBalance(balances, tokenId);
  }

  /// Returns the symbol for a given token ID
  static String getSymbolForTokenId(String tokenId) {
    final currencyName = _tokenToCurrency[tokenId] ?? 'unknown';
    return CurrencySymbolUtil.getSymbolForCurrency(currencyName);
  }

  /// Returns the token ID for a given currency name
  static String? getTokenIdForCurrency(String currencyName) {
    return _currencyToToken[currencyName.toLowerCase()];
  }

  /// Gets all available balances formatted with their symbols
  static Map<String, String> getAllFormattedBalances(
    Map<String, num> balances,
  ) {
    final result = <String, String>{};

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
    Map<String, num> balances,
    String currencyName,
    num requiredAmount,
  ) {
    final balance = getBalanceByCurrency(balances, currencyName);
    return balance >= requiredAmount;
  }
}
