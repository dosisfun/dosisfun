/**
 * Black Market Aegis Service
 * Service integrated with Aegis SDK for real transactions
 */

import { 
  MarketListing, 
  ListingFormData, 
  BuyIngredientData, 
  BuyDrugData,
  BlackMarketFilters
} from '../types/black-market';

const BLACK_MARKET_CONTRACT_ADDRESS = process.env.EXPO_PUBLIC_BLACK_MARKET_CONTRACT;

export class BlackMarketService {
  private contractAddress: string;

  constructor(contractAddress?: string) {
    this.contractAddress = contractAddress || BLACK_MARKET_CONTRACT_ADDRESS;
  }

  /**
   * List a drug in the black market
   */
  async listDrug(data: ListingFormData, aegisAccount: any): Promise<{ listingId: number; txHash: string }> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    try {
      console.log('Listing drug with Aegis:', data);
      
      // Convert nft_token_id from string to u256 (low, high)
      const nftTokenId = BigInt(data.nft_token_id);
      const nftTokenIdLow = (nftTokenId & BigInt('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')).toString();
      const nftTokenIdHigh = (nftTokenId >> BigInt(128)).toString();
      
      // Prepare parameters for the contract
      const params = [
        nftTokenIdLow,      // nft_token_id: u256 (low)
        nftTokenIdHigh,     // nft_token_id: u256 (high)
        data.drug_id        // drug_id: u32
      ];

      // Call the contract
      const result = await aegisAccount.execute(
        this.contractAddress,
        'list_drug',
        params
      );

      console.log('List drug transaction result:', result);
      
      // The contract returns the listing_id as the result
      const listingId = parseInt(result[0], 16);
      
      return {
        listingId,
        txHash: result.transaction_hash
      };
    } catch (error) {
      console.error('Error listing drug with Aegis:', error);
      throw new Error(`Failed to list drug: ${error}`);
    }
  }

  /**
   * Cancel a listing
   */
  async cancelListing(nftTokenId: string, listingId: number, aegisAccount: any): Promise<{ txHash: string }> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    try {
      console.log('Canceling listing with Aegis:', { nftTokenId, listingId });
      
      const params = [
        nftTokenId,    // nft_token_id: u256
        listingId      // listing_id: u32
      ];

      const result = await aegisAccount.execute(
        this.contractAddress,
        'cancel_listing',
        params
      );

      console.log('Cancel listing transaction result:', result);
      
      return {
        txHash: result.transaction_hash
      };
    } catch (error) {
      console.error('Error canceling listing with Aegis:', error);
      throw new Error(`Failed to cancel listing: ${error}`);
    }
  }

  /**
   * Buy a drug from the market
   */
  async buyDrug(data: BuyDrugData, aegisAccount: any): Promise<{ txHash: string }> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    try {
      console.log('Buying drug with Aegis:', data);
      
      // Convert buyer_nft_token_id from string to u256 (low, high)
      const buyerNftTokenId = BigInt(data.buyer_nft_token_id);
      const buyerNftTokenIdLow = (buyerNftTokenId & BigInt('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')).toString();
      const buyerNftTokenIdHigh = (buyerNftTokenId >> BigInt(128)).toString();
      
      const params = [
        buyerNftTokenIdLow,     // buyer_nft_token_id: u256 (low)
        buyerNftTokenIdHigh,    // buyer_nft_token_id: u256 (high)
        data.listing_id         // listing_id: u32
      ];

      const result = await aegisAccount.execute(
        this.contractAddress,
        'buy_drug',
        params
      );

      console.log('Buy drug transaction result:', result);
      
      return {
        txHash: result.transaction_hash
      };
    } catch (error) {
      console.error('Error buying drug with Aegis:', error);
      throw new Error(`Failed to buy drug: ${error}`);
    }
  }

  /**
   * Buy ingredients from the market
   */
  async buyIngredient(data: BuyIngredientData, aegisAccount: any): Promise<{ txHash: string }> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    try {
      console.log('Buying ingredient with Aegis:', data);
      
      // Convert nft_token_id from string to u256 (low, high)
      const nftTokenId = BigInt(data.nft_token_id);
      const nftTokenIdLow = (nftTokenId & BigInt('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')).toString();
      const nftTokenIdHigh = (nftTokenId >> BigInt(128)).toString();
      
      const params = [
        nftTokenIdLow,        // nft_token_id: u256 (low)
        nftTokenIdHigh,       // nft_token_id: u256 (high)
        data.ingredient_id,   // ingredient_id: u32
        data.quantity         // quantity: u32
      ];

      const result = await aegisAccount.execute(
        this.contractAddress,
        'buy_ingredient',
        params
      );

      console.log('Buy ingredient transaction result:', result);
      
      return {
        txHash: result.transaction_hash
      };
    } catch (error) {
      console.error('Error buying ingredient with Aegis:', error);
      throw new Error(`Failed to buy ingredient: ${error}`);
    }
  }

  /**
   * Get a specific listing
   */
  async getListing(listingId: number, aegisAccount: any): Promise<MarketListing> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    try {
      console.log('Getting listing with Aegis:', listingId);
      
      const result = await aegisAccount.call(
        this.contractAddress,
        'get_listing',
        [listingId]
      );

      console.log('Get listing result:', result);
      
      return {
        id: Number(result[0]),
        seller_nft_token_id: result[1], // u256 as string
        drug_id: Number(result[2]),
        price: result[3], // u256 as string
        is_active: Number(result[4]) === 1,
        listed_timestamp: Number(result[5]),
        sold_timestamp: Number(result[6]),
        buyer_nft_token_id: result[7] // u256 as string
      };
    } catch (error) {
      console.error('Error getting listing with Aegis:', error);
      throw new Error(`Failed to get listing: ${error}`);
    }
  }

  /**
   * Get all active listings
   */
  async getActiveListings(filters?: BlackMarketFilters, aegisAccount?: any): Promise<MarketListing[]> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    try {
      console.log('Getting active listings with Aegis');
      
      const result = await aegisAccount.call(
        this.contractAddress,
        'get_active_listings',
        []
      );

      console.log('Get active listings result:', result);
      
      const listings: MarketListing[] = [];
      
      if (result && Array.isArray(result)) {
        for (let i = 0; i < result.length; i += 8) {
          if (i + 7 < result.length) {
            const listing: MarketListing = {
              id: Number(result[i]),
              seller_nft_token_id: result[i + 1],
              drug_id: Number(result[i + 2]),
              price: result[i + 3],
              is_active: Number(result[i + 4]) === 1,
              listed_timestamp: Number(result[i + 5]),
              sold_timestamp: Number(result[i + 6]),
              buyer_nft_token_id: result[i + 7]
            };
            listings.push(listing);
          }
        }
      }
      
      return listings;
    } catch (error) {
      console.error('Error getting active listings with Aegis:', error);
      throw new Error(`Failed to get active listings: ${error}`);
    }
  }

  /**
   * Get listings of a specific seller
   */
  async getSellerListings(nftTokenId: string, aegisAccount?: any): Promise<MarketListing[]> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    try {
      console.log('Getting seller listings with Aegis:', nftTokenId);
      
      const result = await aegisAccount.call(
        this.contractAddress,
        'get_seller_listings',
        [nftTokenId]
      );

      console.log('Get seller listings result:', result);
      
      const listings: MarketListing[] = [];
      
      if (result && Array.isArray(result)) {
        for (let i = 0; i < result.length; i += 8) {
          if (i + 7 < result.length) {
            const listing: MarketListing = {
              id: Number(result[i]),
              seller_nft_token_id: result[i + 1],
              drug_id: Number(result[i + 2]),
              price: result[i + 3],
              is_active: Number(result[i + 4]) === 1,
              listed_timestamp: Number(result[i + 5]),
              sold_timestamp: Number(result[i + 6]),
              buyer_nft_token_id: result[i + 7]
            };
            listings.push(listing);
          }
        }
      }
      
      return listings;
    } catch (error) {
      console.error('Error getting seller listings with Aegis:', error);
      throw new Error(`Failed to get seller listings: ${error}`);
    }
  }

  /**
   * Format price from wei to STRK
   */
  formatPrice(priceInWei: string, decimals: number = 18): string {
    const wei = BigInt(priceInWei);
    const strk = wei / BigInt(10 ** decimals);
    const remainder = wei % BigInt(10 ** decimals);
    const remainderStr = remainder.toString().padStart(decimals, '0');
    
    if (remainder === BigInt(0)) {
      return strk.toString();
    }
    
    return `${strk}.${remainderStr.slice(0, 4)}`;
  }

  /**
   * Convert STRK to wei
   */
  parsePrice(priceInStrk: string, decimals: number = 18): string {
    const [whole, decimal = ''] = priceInStrk.split('.');
    const paddedDecimal = decimal.padEnd(decimals, '0').slice(0, decimals);
    return (BigInt(whole) * BigInt(10 ** decimals) + BigInt(paddedDecimal)).toString();
  }
}

// Singleton instance of the service
export const blackMarketService = new BlackMarketService();
