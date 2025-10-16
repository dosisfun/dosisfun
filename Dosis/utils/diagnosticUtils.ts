/**
 * Utilidades para diagnosticar problemas de transacciones
 */

export const diagnoseWalletState = async (aegisAccount: any) => {
  console.log('=== DIAGNOSTIC WALLET STATE ===');
  
  try {
    // 1. Verificar estructura del objeto aegisAccount
    console.log('aegisAccount keys:', Object.keys(aegisAccount || {}));
    
    // 2. Verificar address
    const address = aegisAccount?.address || aegisAccount?.account?.address;
    console.log('Wallet address:', address);
    
    // 3. Verificar balance usando diferentes métodos
    console.log('--- Checking Balance ---');
    
    // Método 1: getBalance directo
    if (aegisAccount.getBalance) {
      try {
        const balance1 = await aegisAccount.getBalance();
        console.log('getBalance() result:', balance1);
      } catch (e) {
        console.log('getBalance() error:', e);
      }
    }
    
    // Método 2: getTokenBalance
    if (aegisAccount.getTokenBalance) {
      try {
        // STRK token address en Sepolia
        const strkAddress = '0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d';
        const balance2 = await aegisAccount.getTokenBalance(strkAddress);
        console.log('getTokenBalance(STRK) result:', balance2);
      } catch (e) {
        console.log('getTokenBalance() error:', e);
      }
    }
    
    // Método 3: provider.getBalance
    if (aegisAccount.provider?.getBalance && address) {
      try {
        const balance3 = await aegisAccount.provider.getBalance(address);
        console.log('provider.getBalance() result:', balance3);
      } catch (e) {
        console.log('provider.getBalance() error:', e);
      }
    }
    
    // 4. Verificar configuración del paymaster
    console.log('--- Checking Paymaster Config ---');
    console.log('Paymaster API Key:', process.env.EXPO_PUBLIC_AEGIS_PAYMASTER_API_KEY ? 'Present' : 'Missing');
    
    // 5. Verificar métodos disponibles
    console.log('--- Available Methods ---');
    const methods = [
      'execute', 'call', 'getBalance', 'getTokenBalance', 
      'provider', 'account', 'address'
    ];
    
    methods.forEach(method => {
      console.log(`${method}:`, typeof aegisAccount?.[method]);
    });
    
    console.log('=== END DIAGNOSTIC ===');
    
  } catch (error) {
    console.error('Diagnostic error:', error);
  }
};

export const testSimpleTransaction = async (aegisAccount: any) => {
  console.log('=== TESTING SIMPLE TRANSACTION ===');
  
  try {
    // Intentar una transacción muy simple
    const testContract = '0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d'; // STRK token
    
    const result = await aegisAccount.call(
      testContract,
      'balanceOf',
      [aegisAccount.address]
    );
    
    console.log('Simple call result:', result);
    return true;
    
  } catch (error) {
    console.error('Simple transaction test failed:', error);
    return false;
  }
};
