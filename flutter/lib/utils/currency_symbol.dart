class CurrencySymbolUtil {
  /// Returns the currency symbol for a given currency label
  static String getSymbolForCurrency(String currencyLabel) {
    switch (currencyLabel.toLowerCase()) {
      case 'good_dollar':
        return 'G\$';
      case 'celo_dollar':
        return 'cUSD';
      case 'tether_usd':
        return 'USDT';
      case 'usd_coin':
        return 'USDC';
      default:
        return currencyLabel;
    }
  }

  static String getNameForCurrency(int? tokenId) {
    switch (tokenId) {
      case 1:
        return "good_dollar";
      case 2:
        return 'celo_dollar';
      case 3:
        return 'tether_usd';
      case 4:
        return 'usd_coin';
      default:
        return "good_dollar";
    }
  }
}
