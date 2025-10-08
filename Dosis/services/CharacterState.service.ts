/**
 * Character State Service
 * Handles fetching and parsing character state data from NFT attributes
 */

import { fetchNFTDetail } from '../app/api/character-state';
import {
  VoyagerNFTDetailResponse,
  VoyagerNFTAttribute,
  CharacterStats,
  CharacterData
} from '../types/character-state';

/**
 * Helper function to extract and convert attribute values by trait type
 * Handles missing attributes with sensible defaults
 *
 * @param attributes - Array of NFT attributes from API
 * @param traitType - The trait_type to search for
 * @param defaultValue - Default value if attribute is missing
 * @returns Converted value with appropriate type
 */
function getAttributeValue(
  attributes: VoyagerNFTAttribute[],
  traitType: string,
  defaultValue: any
): any {
  const attr = attributes.find(a => a.trait_type === traitType);
  if (!attr) return defaultValue;

  // Handle numeric values
  if (typeof defaultValue === 'number') {
    const parsed = parseInt(attr.value, 10);
    return isNaN(parsed) ? defaultValue : parsed;
  }

  // Handle boolean values
  if (typeof defaultValue === 'boolean') {
    return attr.value.toLowerCase() === 'true';
  }

  return attr.value;
}

/**
 * Parse attributes array and extract character statistics
 * Handles missing attributes with sensible defaults
 *
 * @param attributes - Array of NFT attributes from Voyager API
 * @returns Parsed character statistics
 */
export function parseCharacterStats(attributes: VoyagerNFTAttribute[]): CharacterStats {
  return {
    level: getAttributeValue(attributes, 'Level', 0),
    experience: getAttributeValue(attributes, 'Experience', 0),
    reputation: getAttributeValue(attributes, 'Reputation', 0),
    total_drugs_created: getAttributeValue(attributes, 'Total Drugs Created', 0),
    successful_crafts: getAttributeValue(attributes, 'Successful Crafts', 0),
    failed_crafts: getAttributeValue(attributes, 'Failed Crafts', 0),
    creation_timestamp: getAttributeValue(attributes, 'Creation Timestamp', 0),
    last_active_timestamp: getAttributeValue(attributes, 'Last Active Timestamp', 0),
    is_minted: getAttributeValue(attributes, 'Is Minted', false),
    is_active: getAttributeValue(attributes, 'Is Active', false),
  };
}

/**
 * Transform Voyager API response to CharacterData domain object
 *
 * @param response - Raw API response from Voyager NFT detail endpoint
 * @returns Transformed character data for application use
 */
export function transformToCharacterData(
  response: VoyagerNFTDetailResponse
): CharacterData {
  const stats = parseCharacterStats(response.attributes);

  return {
    tokenId: response.token_id,
    contractAddress: response.contract_address,
    owner: response.balance.owner_address,
    name: response.name || `DOSIS NFT #${response.token_id}`,
    description: response.description,
    imageUrl: response.image_url,
    imageSmallUrl: response.image_small_url,
    imageLargeUrl: response.image_large_url,
    stats,
    mintingInfo: {
      mintedBy: response.minted_by_address,
      mintedAt: response.minted_at_timestamp,
      blockNumber: response.minted_at_block_number,
      transactionHash: response.minted_at_transaction_hash,
    },
  };
}

/**
 * Fetch complete character data for a specific NFT token
 * Includes metadata, images, stats, and minting information
 *
 * @param tokenId - The NFT token ID
 * @returns Complete character data with stats
 * @throws Error if fetch or parsing fails
 */
export async function getCharacterData(tokenId: string): Promise<CharacterData> {
  try {
    const response = await fetchNFTDetail(tokenId);
    return transformToCharacterData(response);
  } catch (error: any) {
    console.error('Error getting character data:', error.message);
    throw new Error(`Failed to get character data for token ${tokenId}: ${error.message}`);
  }
}

/**
 * Fetch character stats only (lighter weight than full character data)
 * Returns just the parsed statistics without metadata
 *
 * @param tokenId - The NFT token ID
 * @returns Character statistics
 * @throws Error if fetch or parsing fails
 */
export async function getCharacterStats(tokenId: string): Promise<CharacterStats> {
  try {
    const response = await fetchNFTDetail(tokenId);
    return parseCharacterStats(response.attributes);
  } catch (error: any) {
    console.error('Error getting character stats:', error.message);
    throw new Error(`Failed to get character stats for token ${tokenId}: ${error.message}`);
  }
}

/**
 * Check if a character is minted and active
 * Useful for filtering or conditional UI logic
 *
 * @param tokenId - The NFT token ID
 * @returns Object with minting and activity status
 */
export async function getCharacterStatus(tokenId: string): Promise<{
  isMinted: boolean;
  isActive: boolean;
}> {
  try {
    const stats = await getCharacterStats(tokenId);
    return {
      isMinted: stats.is_minted,
      isActive: stats.is_active,
    };
  } catch (error) {
    console.error(`Error getting character status for token ${tokenId}:`, error);
    // Default to false on error to avoid blocking UI
    return { isMinted: false, isActive: false };
  }
}
