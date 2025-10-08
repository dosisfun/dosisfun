import { fetchNFTsByAddresses, fetchNFTsByAddress } from '../app/api/nfts';
import { VoyagerNFT, VoyagerNFTResponse, MintedNFTItem, VoyagerNFTItemsResponse } from '../types/voyager';

export async function getNFTsByAddress(addresses: string[]): Promise<VoyagerNFTResponse> {
  try {
    return await fetchNFTsByAddresses(addresses);
  } catch (error: any) {
    console.error('Error fetching NFTs:', error.message);
    throw new Error(`Failed to fetch NFTs: ${error.message}`);
  }
}

export async function getDosisNFTsByAddress(address: string): Promise<VoyagerNFT[]> {
  try {
    return await fetchNFTsByAddress(address);
  } catch (error: any) {
    console.error('Error fetching NFTs for address:', error.message);
    throw new Error(`Failed to fetch NFTs for address: ${error.message}`);
  }
}


export async function getAllMintedNFTs(limit: number = 100): Promise<VoyagerNFTItemsResponse> {
  try {
    const DOSIS_CONTRACT = '0x05bb9c4d7f7b422c281c65e8310da8a753562f274066ad3a6db48447cba2df91';
    const url = `https://sepolia.voyager.online/api/nft-items?contract_address=${DOSIS_CONTRACT}&limit=${limit}`;

    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  } catch (error: any) {
    console.error('Error fetching minted NFTs:', error.message);
    throw new Error(`Failed to fetch minted NFTs: ${error.message}`);
  }
}
