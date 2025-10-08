/**
 * API service for fetching NFTs using Voyager blockchain explorer
 * This handles the bulk balance endpoint for fetching NFTs owned by addresses
 *
 * Note: This endpoint does NOT include character attributes/stats.
 * For individual NFT details with character state, use character-state.ts
 */

import { DosisNFT, DosisNFTResponse } from '../../types/dosis';
import { VOYAGER_BASE_URL, DOSIS_NFT_ADDRESS } from '../../constants/contracts';

const DOSIS_NFT_CONTRACT = DOSIS_NFT_ADDRESS;

interface VoyagerNFTItem {
  contract_address: string;
  token_id: string;
  token_name: string | null;
  token_description: string;
  image_url: string;
  image_small_url: string;
  image_large_url: string;
  collection_name: string;
  last_transfer_time: number;
}

interface VoyagerBalanceResponse {
  items: VoyagerNFTItem[];
}

/**
 * Fetch NFTs for multiple addresses using Voyager API
 */
export async function fetchNFTsByAddresses(addresses: string[]): Promise<DosisNFTResponse> {
  try {
    const allNFTs: DosisNFT[] = [];
    
    for (const address of addresses) {
      try {
        const balanceResponse = await fetch(
          `${VOYAGER_BASE_URL}/nft-contract-balance?owner_address=${address}`
        );

        if (!balanceResponse.ok) {
          console.error(`Error fetching balance for ${address}:`, balanceResponse.status);
          continue;
        }

        const balanceData: VoyagerBalanceResponse = await balanceResponse.json();

        // Filter and sort DOSIS NFTs
        const dosisNFTs = balanceData.items
          ?.filter((item: VoyagerNFTItem) => 
            item.contract_address?.toLowerCase() === DOSIS_NFT_CONTRACT.toLowerCase()
          )
          ?.sort((a, b) => parseInt(a.token_id) - parseInt(b.token_id)) || [];

        if (dosisNFTs.length === 0) {
          continue;
        }

        // Transform NFTs to our format
        for (const nftItem of dosisNFTs) {
          const transformedNFT: DosisNFT = {
            contract_address: nftItem.contract_address,
            token_id: nftItem.token_id,
            name: nftItem.token_name || `DOSIS NFT #${nftItem.token_id}`,
            description: nftItem.token_description || '',
            image: nftItem.image_url || '',
            owner: address,
            metadata: {
              image_small: nftItem.image_small_url,
              image_large: nftItem.image_large_url,
              collection_name: nftItem.collection_name,
              last_transfer_time: nftItem.last_transfer_time
            }
          };

          allNFTs.push(transformedNFT);
        }
      } catch (error) {
        console.error(`Error fetching NFTs for address ${address}:`, error);
        continue;
      }
    }

    return {
      ownedNfts: allNFTs,
      totalCount: allNFTs.length
    };
    
  } catch (error) {
    console.error('API service error:', error);
    throw new Error('Failed to fetch NFTs from Voyager API');
  }
}

/**
 * Fetch NFTs for a single address
 */
export async function fetchNFTsByAddress(address: string): Promise<DosisNFT[]> {
  const response = await fetchNFTsByAddresses([address]);
  return response.ownedNfts;
}
