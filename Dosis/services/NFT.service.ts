import { getDosisNFTsByAddress } from './VoyagerNFT.service';
import { VoyagerNFT } from '../types/voyager';
import { NFTData, NFTMetadata } from '../types/nft';

const DOSIS_NFT_CONTRACT = '0x05bb9c4d7f7b422c281c65e8310da8a753562f274066ad3a6db48447cba2df91';

/**
 * Transform Voyager NFT data to our app format
 */
function transformVoyagerNFT(voyagerNFT: VoyagerNFT): NFTData {
  return {
    id: voyagerNFT.token_id,
    name: voyagerNFT.name || `DOSIS NFT #${voyagerNFT.token_id}`,
    image: voyagerNFT.image || '',
    description: voyagerNFT.description || '',
    tokenId: voyagerNFT.token_id,
    contractAddress: voyagerNFT.contract_address,
    owner: voyagerNFT.owner || '',
    metadata: voyagerNFT.metadata
  };
}

/**
 * Fetch NFTs owned by a specific address using Voyager API
 */
export async function fetchUserNFTs(address: string): Promise<NFTData[]> {
  try {
    console.log('Fetching NFTs for address:', address);
    
    // Get NFTs from Voyager
    const voyagerNFTs = await getDosisNFTsByAddress(address);
    console.log('Voyager NFTs received:', voyagerNFTs.length);
    
    // Transform to our format
    const nfts = voyagerNFTs.map(transformVoyagerNFT);
    console.log('Transformed NFTs:', nfts.length);
    
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
      url = metadataUrl.replace('ipfs://', 'https://ipfs.io/ipfs/');
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
    return imageUrl.replace('ipfs://', 'https://ipfs.io/ipfs/');
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
