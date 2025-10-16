/**
 * Utilities to manage wallet and balance
 */

/**
 * Verify if there is enough balance for a transaction
 */
export const checkBalance = async (aegisAccount: any, requiredAmount: string = '0.001'): Promise<boolean> => {
  try {
    if (!aegisAccount) {
      console.error('No Aegis account provided');
      return false;
    }

    // Use getTokenBalance that we know works
    if (aegisAccount.getTokenBalance) {
      const strkAddress = '0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d';
      const balance = await aegisAccount.getTokenBalance(strkAddress);
      const balanceInStrk = parseFloat(balance.toString());
      const required = parseFloat(requiredAmount);

      console.log(`Current balance: ${balanceInStrk} STRK, Required: ${required} STRK`);
      
      return balanceInStrk >= required;
    } else {
      console.error('getTokenBalance method not available');
      return false;
    }
  } catch (error) {
    console.error('Error checking balance:', error);
    return false;
  }
};

/**
 * Get the current balance in STRK
 */
export const getBalanceInStrk = async (aegisAccount: any): Promise<string> => {
  try {
    if (!aegisAccount) {
      return '0';
    }

    // Use getTokenBalance that we know works
    if (aegisAccount.getTokenBalance) {
      // STRK token address in Sepolia
      const strkAddress = '0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d';
      const balance = await aegisAccount.getTokenBalance(strkAddress);
      
      // The balance is already in the correct format
      return balance.toString();
    } else {
      console.warn('getTokenBalance method not found on aegisAccount');
      return '0';
    }
  } catch (error) {
    console.error('Error getting balance:', error);
    return '0';
  }
};

/**
 * Format the balance to display
 */
export const formatBalance = (balance: string): string => {
  const num = parseFloat(balance);
  if (num === 0) return '0.000000 STRK';
  if (num < 0.001) return `${num.toFixed(8)} STRK`;
  return `${num.toFixed(6)} STRK`;
};
