// lib/utils/token_address_util.dart
import 'package:pax/utils/token_balance_util.dart';

class TokenAddressUtil {
  /// Returns the contract address for a given currency ID
  static String getAddressForCurrency(int tokenId) {
    final address = TokenBalanceUtil.getTokenAddress(tokenId);
    if (address == null) {
      throw Exception('No address mapping found for token ID: $tokenId');
    }
    return address;
  }

  /// Returns the token ID for a given address
  static int? getTokenIdForAddress(String address) {
    return TokenBalanceUtil.getTokenIdByAddress(address);
  }

  /// Returns the number of decimals for a token
  static int getDecimalsForCurrency(int tokenId) {
    return TokenBalanceUtil.getTokenDecimals(tokenId);
  }

  /// Checks if an address is a valid token address
  static bool isValidTokenAddress(String address) {
    return TokenBalanceUtil.getTokenIdByAddress(address) != null;
  }

  /// Converts a human-readable amount to token units (wei) based on decimals
  static BigInt convertToTokenUnits(double amount, int tokenId) {
    return TokenBalanceUtil.convertToSmallestUnit(amount, tokenId);
  }
}
