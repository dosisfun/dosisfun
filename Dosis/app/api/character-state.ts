/**
 * API client for fetching individual NFT character state from Voyager blockchain explorer
 * This handles the detailed NFT endpoint that includes character attributes
 */

import { VoyagerNFTDetailResponse } from '../../types/character-state';
import { DOSIS_NFT_ADDRESS, VOYAGER_BASE_URL } from '../../constants/contracts';

const REQUEST_TIMEOUT = 10000; // 10 seconds
const VOYAGER_NFT_BASE_URL = VOYAGER_BASE_URL.replace('/api', '');

/**
 * Fetch detailed NFT data including character attributes from Voyager API
 *
 * @param tokenId - The NFT token ID to fetch
 * @returns Complete NFT detail including attributes array with character stats
 * @throws Error if fetch fails or response is invalid
 */
export async function fetchNFTDetail(tokenId: string): Promise<VoyagerNFTDetailResponse> {
  try {
    const url = `${VOYAGER_NFT_BASE_URL}/nft/${DOSIS_NFT_ADDRESS}/${tokenId}`;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), REQUEST_TIMEOUT);

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
      },
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      if (response.status === 403) {
        throw new Error(`Access forbidden (403): Unable to fetch NFT detail for token ${tokenId}`);
      } else if (response.status === 404) {
        throw new Error(`NFT not found (404): Token ${tokenId} does not exist`);
      } else if (response.status >= 500) {
        throw new Error(`Server error (${response.status}): Voyager API is currently unavailable`);
      } else {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
    }

    const data: VoyagerNFTDetailResponse = await response.json();

    // Validate required fields
    if (!data.token_id || !data.contract_address) {
      throw new Error('Invalid NFT detail response: missing required fields (token_id or contract_address)');
    }

    if (!Array.isArray(data.attributes)) {
      throw new Error('Invalid NFT detail response: attributes must be an array');
    }

    return data;
  } catch (error: any) {
    // Handle abort/timeout errors
    if (error.name === 'AbortError') {
      console.error(`Request timeout for token ${tokenId}`);
      throw new Error(`Request timeout: Failed to fetch NFT detail within ${REQUEST_TIMEOUT}ms`);
    }

    console.error(`Error fetching NFT detail for token ${tokenId}:`, error.message);
    throw error;
  }
}

/**
 * Fetch multiple NFT details in sequence
 * Note: Uses sequential fetching with delay to avoid rate limiting
 *
 * @param tokenIds - Array of token IDs to fetch
 * @returns Array of NFT detail responses (skips tokens that fail)
 */
export async function fetchMultipleNFTDetails(
  tokenIds: string[]
): Promise<VoyagerNFTDetailResponse[]> {
  const results: VoyagerNFTDetailResponse[] = [];

  for (const tokenId of tokenIds) {
    try {
      const detail = await fetchNFTDetail(tokenId);
      results.push(detail);

      // Small delay to avoid rate limiting (only if not last item)
      if (tokenId !== tokenIds[tokenIds.length - 1]) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    } catch (error) {
      console.error(`Skipping token ${tokenId} due to error:`, error);
      // Continue fetching other tokens even if one fails
    }
  }

  return results;
}
