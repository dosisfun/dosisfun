/**
 * Character state types for NFT character data from Voyager blockchain explorer API
 */

/**
 * Raw API response from Voyager NFT detail endpoint
 * Endpoint: https://sepolia.voyager.online/nft/{contract_address}/{token_id}
 */
export interface VoyagerNFTDetailResponse {
  contract_address: string;
  collection_name: string;
  token_id: string;
  contract_type: number;
  name: string | null;
  description: string;
  external_url: string | null;
  attributes: VoyagerNFTAttribute[];
  image_url: string;
  image_small_url: string;
  image_large_url: string;
  youtube_url: string | null;
  animation_url: string | null;
  minted_by_address: string;
  minted_at_timestamp: number;
  minted_at_block_number: number;
  minted_at_transaction_hash: string;
  is_verified: boolean;
  balance: {
    contract_address: string;
    token_id: string;
    owner_address: string;
    last_transfer_time: number;
    balance: number;
  };
  latest_activity: {
    token_id: string;
    transaction_hash: string;
    timestamp: number;
    type: string;
  };
}

/**
 * NFT attribute from Voyager API response
 * Attributes contain character statistics as trait_type/value pairs
 */
export interface VoyagerNFTAttribute {
  trait_type: string;
  value: string;
}

/**
 * Parsed character statistics from NFT attributes
 * These are extracted from the attributes array in the Voyager API response
 */
export interface CharacterStats {
  level: number;
  experience: number;
  reputation: number;
  total_drugs_created: number;
  successful_crafts: number;
  failed_crafts: number;
  creation_timestamp: number;
  last_active_timestamp: number;
  is_minted: boolean;
  is_active: boolean;
}

/**
 * Complete character data combining NFT metadata and stats
 * This is the domain model used throughout the application
 */
export interface CharacterData {
  tokenId: string;
  contractAddress: string;
  owner: string;
  name: string;
  description: string;
  imageUrl: string;
  imageSmallUrl: string;
  imageLargeUrl: string;
  stats: CharacterStats;
  mintingInfo: {
    mintedBy: string;
    mintedAt: number;
    blockNumber: number;
    transactionHash: string;
  };
}
