/**
 * Contract Addresses Configuration
 * Update these addresses after deploying your contracts
 */

// Environment variables are loaded from .env file

// Starknet Sepolia Network Contract Addresses
export const CONTRACT_ADDRESSES = {
  // NFT Contract (already deployed)
  DOSIS_NFT: process.env.EXPO_PUBLIC_DOSIS_NFT_CONTRACT || '0x05bb9c4d7f7b422c281c65e8310da8a753562f274066ad3a6db48447cba2df91',
  
  // Game Contracts (to be deployed)
  DRUG_CRAFTING: process.env.EXPO_PUBLIC_DRUG_CRAFTING_CONTRACT || '0x0',
  BLACK_MARKET: process.env.EXPO_PUBLIC_BLACK_MARKET_CONTRACT || '0x0',
  
  // Other contracts (if needed)
  RECIPE_SYSTEM: process.env.EXPO_PUBLIC_RECIPE_SYSTEM_CONTRACT || '0x0',
  PLAYER_TOKEN: process.env.EXPO_PUBLIC_PLAYER_TOKEN_CONTRACT || '0x0',
};

// Network Configuration
export const NETWORK_CONFIG = {
  name: 'SN_SEPOLIA',
  rpcUrl: process.env.EXPO_PUBLIC_STARKNET_RPC_URL || 'https://starknet-sepolia.public.blastapi.io/rpc/v0_7',
  chainId: '0x534e5f5345504f4c4941', // SN_SEPOLIA chain ID
  explorerUrl: process.env.EXPO_PUBLIC_VOYAGER_EXPLORER_URL || 'https://sepolia.voyager.online',
};

// Aegis Configuration
export const AEGIS_CONFIG = {
  appName: process.env.EXPO_PUBLIC_AEGIS_APP_NAME || 'dosisfun',
  appId: process.env.EXPO_PUBLIC_AEGIS_APP_ID || 'app-pwoeZT2RJ5SbVrz9yMdzp8sRXYkLrL6Z',
  paymasterApiKey: process.env.EXPO_PUBLIC_AEGIS_PAYMASTER_API_KEY || 'c37c52b7-ea5a-4426-8121-329a78354b0b',
};

// Voyager API Configuration
export const VOYAGER_CONFIG = {
  baseUrl: process.env.EXPO_PUBLIC_VOYAGER_BASE_URL || 'https://sepolia.voyager.online/api',
  explorerUrl: process.env.EXPO_PUBLIC_VOYAGER_EXPLORER_URL || 'https://sepolia.voyager.online',
};

// Individual exports for backward compatibility
export const VOYAGER_BASE_URL = VOYAGER_CONFIG.baseUrl || 'https://sepolia.voyager.online/api';
export const VOYAGER_EXPLORER_URL = VOYAGER_CONFIG.explorerUrl || 'https://sepolia.voyager.online';
export const DOSIS_NFT_ADDRESS = CONTRACT_ADDRESSES.DOSIS_NFT || '0x05bb9c4d7f7b422c281c65e8310da8a753562f274066ad3a6db48447cba2df91';

// IPFS Configuration
export const IPFS_CONFIG = {
  gateway: process.env.EXPO_PUBLIC_IPFS_GATEWAY || 'https://ipfs.io/ipfs/',
};

// Helper function to validate contract address format
export const isValidContractAddress = (address: string): boolean => {
  if (!address || address === '0x0' || address === '') return false;
  // Check if it's a valid hex address (starts with 0x and has correct length)
  return /^0x[0-9a-fA-F]{63,64}$/.test(address);
};

// Helper function to check if contracts are deployed
export const isContractDeployed = (contractAddress: string): boolean => {
  return isValidContractAddress(contractAddress);
};

// Helper function to get contract deployment status
export const getContractStatus = () => {
  return {
    nft: isContractDeployed(CONTRACT_ADDRESSES.DOSIS_NFT),
    drugCrafting: isContractDeployed(CONTRACT_ADDRESSES.DRUG_CRAFTING),
    blackMarket: isContractDeployed(CONTRACT_ADDRESSES.BLACK_MARKET),
    recipeSystem: isContractDeployed(CONTRACT_ADDRESSES.RECIPE_SYSTEM),
    playerToken: isContractDeployed(CONTRACT_ADDRESSES.PLAYER_TOKEN),
  };
};