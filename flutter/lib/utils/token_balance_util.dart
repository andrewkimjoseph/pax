import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pax/models/local/token_info_model.dart';
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

  /// Defines all supported tokens with their complete information
  static final Map<int, TokenInfo> _tokenInfo = {
    1: TokenInfo(
      id: 1,
      name: 'good_dollar',
      symbol: CurrencySymbolUtil.getSymbolForCurrency('good_dollar'),
      address: '0x62B8B11039FcfE5aB0C56E502b1C372A3d2a9c7A',
      decimals: 18,
    ),
    2: TokenInfo(
      id: 2,
      name: 'celo_dollar',
      symbol: CurrencySymbolUtil.getSymbolForCurrency('celo_dollar'),
      address: '0x765de816845861e75a25fca122bb6898b8b1282a',
      decimals: 18,
    ),
    3: TokenInfo(
      id: 3,
      name: 'tether_usd',
      symbol: CurrencySymbolUtil.getSymbolForCurrency('tether_usd'),
      address: '0x48065fbBE25f71C9282ddf5e1cD6D6A887483D5e',
      decimals: 6,
    ),
    4: TokenInfo(
      id: 4,
      name: 'usd_coin',
      symbol: CurrencySymbolUtil.getSymbolForCurrency('usd_coin'),
      address: '0xcebA9300f2b948710d2653dD7B07f33A8B32118C',
      decimals: 6,
    ),
  };

  /// Returns the RewardCurrency for a given token ID
  static TokenInfo? getTokenInfo(int tokenId) {
    return _tokenInfo[tokenId];
  }

  /// Returns the contract address for a given token ID
  static String? getTokenAddress(int tokenId) {
    final currency = _tokenInfo[tokenId];
    return currency?.address;
  }

  /// Returns the decimals for a given token ID
  static int getTokenDecimals(int tokenId) {
    final currency = _tokenInfo[tokenId];
    return currency?.decimals ?? 18; // Default to 18 decimals if not found
  }

  /// Returns all supported tokens
  static List<TokenInfo> getAllTokens() {
    return _tokenInfo.values.toList();
  }

  /// Returns token ID for a given address
  static int? getTokenIdByAddress(String address) {
    final normalizedAddress = address.toLowerCase();
    for (final entry in _tokenInfo.entries) {
      if (entry.value.address.toLowerCase() == normalizedAddress) {
        return entry.key;
      }
    }
    return null;
  }

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
    final NumberFormat formatter = NumberFormat('#,##0.00', locale);

    // Format the number
    final formattedNumber = formatter.format(rawBalance);

    // Add symbol if requested
    if (includeSymbol) {
      final symbol = CurrencySymbolUtil.getSymbolForCurrency(currencyName);
      return '$symbol $formattedNumber';
    }

    return formattedNumber;
  }

  static String getLocaleFormattedAmountNoDecimals(num amount) {
    // Get the raw balance
    final locale = Intl.getCurrentLocale();

    // Create formatter based on whether to include decimals
    final NumberFormat formatter = NumberFormat('#,###', locale);

    // Format the number
    final formattedNumber = formatter.format(amount);

    return formattedNumber;
  }

  static String getLocaleFormattedAmount(num amount) {
    // Get the raw balance
    final locale = Intl.getCurrentLocale();

    // Create formatter based on whether to include decimals
    final NumberFormat formatter = NumberFormat('#,###.######', locale);

    // Format the number
    final formattedNumber = formatter.format(amount);

    return formattedNumber;
  }

  /// Returns the symbol for a given token ID
  static String getSymbolForTokenId(int tokenId) {
    final currency = _tokenInfo[tokenId];
    if (currency != null) {
      return currency.symbol;
    }

    // Fallback to old method
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

  /// Converts a decimal amount to the smallest unit (wei) based on token decimals
  static BigInt convertToSmallestUnit(double amount, int tokenId) {
    final decimals = getTokenDecimals(tokenId);
    final multiplier = BigInt.from(10).pow(decimals);
    return (BigInt.from(amount * 100000) * multiplier) ~/ BigInt.from(100000);
  }

  /// Helper function to calculate powers of 10 for decimal conversion
  static int pow10(int exponent) {
    int result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
