/**
 * Contract addresses and configuration
 * All values are loaded from environment variables
 */

// DOSIS NFT Contract (Sepolia)
export const DOSIS_NFT_ADDRESS = process.env.EXPO_PUBLIC_DOSIS_NFT_CONTRACT || '';

// Voyager API endpoints
export const VOYAGER_BASE_URL = process.env.EXPO_PUBLIC_VOYAGER_BASE_URL || '';

// IPFS Gateway
export const IPFS_GATEWAY = process.env.EXPO_PUBLIC_IPFS_GATEWAY || '';

// Network configuration
export const NETWORK_CONFIG = {
  sepolia: {
    name: 'Starknet Sepolia',
    chainId: '0x534e5f5345504f4c4941',
    rpcUrl: process.env.EXPO_PUBLIC_STARKNET_RPC_URL || '',
    explorerUrl: process.env.EXPO_PUBLIC_VOYAGER_EXPLORER_URL || ''
  }
};
