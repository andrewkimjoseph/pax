// utils/currencyUtils.ts

/**
 * Returns the currency symbol for a given currency label
 * @param currencyLabel The label of the currency
 * @returns The symbol for the given currency
 */
export function getSymbolForCurrency(currencyLabel: string): string {
  switch (currencyLabel.toLowerCase()) {
    case 'good_dollar':
      return 'G$';
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

/**
 * Returns the currency name for a given token ID
 * @param tokenId The token ID
 * @returns The name of the currency
 */
export function getNameForCurrency(tokenId?: number): string {
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

/**
 * Comprehensive currency utility that combines both functions
 * @param input Either a token ID or a currency label
 * @returns The appropriate currency symbol
 */
export function getCurrencySymbol(input: string | number | undefined): string {
  if (typeof input === 'undefined') {
    return 'G$'; // Default to Good Dollar
  }
  
  if (typeof input === 'number') {
    // Input is a token ID
    return getSymbolForCurrency(getNameForCurrency(input));
  } else {
    // Input is a currency label
    return getSymbolForCurrency(input);
  }
}