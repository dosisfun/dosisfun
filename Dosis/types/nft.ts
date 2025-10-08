/**
 * NFT and Character related types for React Native app
 */

import { CharacterStats as DosisCharacterStats } from './character-state';

export interface NFTData {
  id: string;
  name: string;
  image: string;
  description?: string;
  tokenId: string;
  contractAddress: string;
  owner: string;
  metadata?: {
    image_small?: string;
    image_large?: string;
    collection_name?: string;
    last_transfer_time?: number;
  };
  /**
   * Optional character state data fetched from blockchain
   * Only present when explicitly requested via fetchUserNFTs(address, true)
   */
  characterState?: DosisCharacterStats;
}

export interface CharacterStats {
  owner: string;
  character_name: string;
  cash: { low: bigint; high: bigint };
  level: number;
  experience: number;
  reputation: number;
  total_drugs_created: number;
  successful_crafts: number;
  failed_crafts: number;
  creation_timestamp: bigint;
  last_active_timestamp: bigint;
  is_minted: boolean;
  is_active: boolean;
}

export interface NFTFetchResult {
  nfts: NFTData[];
  totalCount: number;
  isLoading: boolean;
  error: string | null;
}

export interface NFTMetadata {
  name: string;
  description: string;
  image: string;
  attributes?: Array<{
    trait_type: string;
    value: string | number;
  }>;
}
