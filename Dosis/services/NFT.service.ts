import { getDosisNFTsByAddress } from './DosisNFT.service';
import { getCharacterStats } from './CharacterState.service';
import { DosisNFT } from '../types/dosis';
import { NFTData, NFTMetadata } from '../types/nft';
import { DOSIS_NFT_ADDRESS, IPFS_GATEWAY } from '../constants/contracts';

/**
 * Transform Dosis NFT data to our app format
 */
function transformDosisNFT(dosisNFT: DosisNFT): NFTData {
  return {
    id: dosisNFT.token_id,
    name: dosisNFT.name || `DOSIS NFT #${dosisNFT.token_id}`,
    image: dosisNFT.image || '',
    description: dosisNFT.description || '',
    tokenId: dosisNFT.token_id,
    contractAddress: dosisNFT.contract_address,
    owner: dosisNFT.owner || '',
    metadata: dosisNFT.metadata
  };
}

/**
 * Enrich NFT data with character state from blockchain
 * Fetches character stats for each NFT and attaches to the object
 * Failures are logged but don't block the NFT from being returned
 *
 * @param nfts - Array of NFT data to enrich
 */
async function enrichWithCharacterState(nfts: NFTData[]): Promise<void> {
  const enrichmentPromises = nfts.map(async (nft) => {
    try {
      const stats = await getCharacterStats(nft.tokenId);
      nft.characterState = stats;
    } catch (error) {
      console.warn(`Failed to fetch character state for token ${nft.tokenId}:`, error);
      // NFT remains without character state but is still usable
    }
  });

  await Promise.allSettled(enrichmentPromises);
}

/**
 * Fetch NFTs owned by a specific address
 * Optionally enriches with character state data
 *
 * @param address - Wallet address
 * @param includeCharacterState - Whether to fetch character stats (default: false)
 * @returns Array of NFT data, optionally with character state
 */
export async function fetchUserNFTs(
  address: string,
  includeCharacterState: boolean = false
): Promise<NFTData[]> {
  try {
    console.log('Fetching NFTs for address:', address);

    // Get NFTs from Voyager balance API
    const dosisNFTs = await getDosisNFTsByAddress(address);
    console.log('Dosis NFTs received:', dosisNFTs.length);

    // Transform to app format
    const nfts = dosisNFTs.map(transformDosisNFT);
    console.log('Transformed NFTs:', nfts.length);

    // Optionally enrich with character state
    if (includeCharacterState) {
      await enrichWithCharacterState(nfts);
    }

    return nfts;
  } catch (error) {
    console.error('Error fetching user NFTs:', error);
    throw error;
  }
}

/**
 * Fetch NFT metadata from IPFS or HTTP URL
 */
export async function fetchNFTMetadata(metadataUrl: string): Promise<NFTMetadata | null> {
  try {
    // Handle IPFS URLs
    let url = metadataUrl;
    if (metadataUrl.startsWith('ipfs://')) {
      url = metadataUrl.replace('ipfs://', IPFS_GATEWAY);
    }
    
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Failed to fetch metadata: ${response.status}`);
    }
    
    const metadata = await response.json();
    return metadata as NFTMetadata;
  } catch (error) {
    console.error('Error fetching NFT metadata:', error);
    return null;
  }
}

/**
 * Get image URL from IPFS or return as-is
 */
export function getImageUrl(imageUrl: string): string {
  if (imageUrl.startsWith('ipfs://')) {
    return imageUrl.replace('ipfs://', IPFS_GATEWAY);
  }
  return imageUrl;
}

/**
 * Check if an address has any NFTs
 */
export async function hasNFTs(address: string): Promise<boolean> {
  try {
    const nfts = await fetchUserNFTs(address);
    return nfts.length > 0;
  } catch (error) {
    console.error('Error checking if user has NFTs:', error);
    return false;
  }
}

/**
 * Get NFT count for an address
 */
export async function getNFTCount(address: string): Promise<number> {
  try {
    const nfts = await fetchUserNFTs(address);
    return nfts.length;
  } catch (error) {
    console.error('Error getting NFT count:', error);
    return 0;
  }
}
