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
}
