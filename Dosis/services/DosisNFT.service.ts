/**
 * Dosis NFT Service
 * Handles fetching NFT data for Dosis NFT characters
 *
 * Note: This service uses the Voyager blockchain explorer API as the data source
 * for querying NFT ownership and minting information on Starknet.
 */

import { fetchNFTsByAddresses, fetchNFTsByAddress } from '../app/api/nfts';
import { DosisNFT, DosisNFTResponse, DosisNFTItem, DosisNFTItemsResponse } from '../types/dosis';
import { DOSIS_NFT_ADDRESS, VOYAGER_BASE_URL } from '../constants/contracts';

/**
 * Get NFTs owned by multiple addresses
 * Uses Voyager blockchain explorer API balance endpoint
 *
 * @param addresses - Array of wallet addresses to query
 * @returns Response containing all NFTs owned by the addresses
 * @throws Error if fetching fails
 */
export async function getNFTsByAddress(addresses: string[]): Promise<DosisNFTResponse> {
  try {
    return await fetchNFTsByAddresses(addresses);
  } catch (error: any) {
    console.error('Error fetching NFTs:', error.message);
    throw new Error(`Failed to fetch NFTs: ${error.message}`);
  }
}

/**
 * Get Dosis NFTs owned by a single address
 * Uses Voyager blockchain explorer API
 *
 * @param address - Wallet address to query
 * @returns Array of Dosis NFTs owned by the address
 * @throws Error if fetching fails
 */
export async function getDosisNFTsByAddress(address: string): Promise<DosisNFT[]> {
  try {
    return await fetchNFTsByAddress(address);
  } catch (error: any) {
    console.error('Error fetching NFTs for address:', error.message);
    throw new Error(`Failed to fetch NFTs for address: ${error.message}`);
  }
}

/**
 * Get all minted NFTs for the Dosis contract
 * Uses Voyager blockchain explorer API to fetch minted items
 *
 * @param limit - Maximum number of NFTs to fetch (default: 100)
 * @returns Response containing minted NFT items with pagination
 * @throws Error if fetching fails
 */
export async function getAllMintedNFTs(limit: number = 100): Promise<DosisNFTItemsResponse> {
  try {
    const url = `${VOYAGER_BASE_URL}/nft-items?contract_address=${DOSIS_NFT_ADDRESS}&limit=${limit}`;

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
