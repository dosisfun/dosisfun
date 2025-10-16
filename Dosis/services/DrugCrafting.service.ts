/**
 * Drug Crafting Service
 * Service to interact with the Drug Crafting System contract
 */

import { 
  CraftingSession, 
  StartCraftingData,
  CraftingProgress
} from '../types/drug-crafting';
import { CONTRACT_ADDRESSES, isValidContractAddress } from '../constants/contracts';

export class DrugCraftingService {
  private contractAddress: string;

  constructor(contractAddress?: string) {
    this.contractAddress = contractAddress || CONTRACT_ADDRESSES.DRUG_CRAFTING;
  }

  /**
   * Start a crafting session
   */
  async startCrafting(data: StartCraftingData, aegisAccount: any): Promise<{ txHash: string }> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    // Check if contract address is valid
    if (!isValidContractAddress(this.contractAddress)) {
      throw new Error('Drug Crafting contract not deployed yet. Please deploy the contract first.');
    }

    try {
      console.log('Starting crafting with Aegis:', data);
      
      const nftTokenId = BigInt(data.nft_token_id);
      const nftTokenIdLow = (nftTokenId & BigInt('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')).toString();
      const nftTokenIdHigh = (nftTokenId >> BigInt(128)).toString();
      
      // For the ByteArray (name), we need to convert it to felt252 format
      const nameAsFelt = data.name;
      
      // For base_ingredients: Array<(u32, u32)>
      const baseIngredientsCalldata = [];
      for (const ingredient of data.base_ingredients) {
        baseIngredientsCalldata.push(ingredient.ingredient_id.toString());
        baseIngredientsCalldata.push(ingredient.quantity.toString());
      }
      
      // For drug_ingredient_ids: Array<u32>
      const drugIngredientIdsCalldata = data.drug_ingredient_ids.map(id => id.toString());
      
      // Build complete calldata
      const calldata = [
        nftTokenIdLow,
        nftTokenIdHigh,
        nameAsFelt,
        ...baseIngredientsCalldata,
        ...drugIngredientIdsCalldata
      ];

      // Call the contract
      const result = await aegisAccount.execute(
        this.contractAddress,
        'start_crafting',
        calldata
      );

      console.log('Start crafting transaction result:', result);
      
      return {
        txHash: result.transaction_hash
      };
    } catch (error) {
      console.error('Error starting crafting with Aegis:', error);
      throw new Error(`Failed to start crafting: ${error}`);
    }
  }

  /**
   * Progress in crafting
   */
  async progressCraft(nftTokenId: string, aegisAccount: any): Promise<{ txHash: string }> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    // Check if contract address is valid
    if (!isValidContractAddress(this.contractAddress)) {
      throw new Error('Drug Crafting contract not deployed yet. Please deploy the contract first.');
    }

    try {
      console.log('Progressing craft with Aegis:', nftTokenId);
      
      // First verify if there is an active session
      const activeSession = await this.getCraftingSession(nftTokenId, aegisAccount);
      if (!activeSession || activeSession.drug_name === '0' || activeSession.drug_name === '0x0') {
        throw new Error('No active crafting session found for this NFT. Please start a new crafting session first.');
      }
      
      // Convert u256 to low and high
      const tokenId = BigInt(nftTokenId);
      const tokenIdLow = (tokenId & BigInt('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')).toString();
      const tokenIdHigh = (tokenId >> BigInt(128)).toString();
      
      const calldata = [
        tokenIdLow,
        tokenIdHigh
      ];

      const result = await aegisAccount.execute(
        this.contractAddress,
        'progress_craft',
        calldata
      );

      console.log('Progress craft transaction result:', result);
      
      return {
        txHash: result.transaction_hash
      };
    } catch (error) {
      console.error('Error progressing craft with Aegis:', error);
      
      // Improve error message
      if (error.toString().includes('AVNU paymaster')) {
        throw new Error('Transaction failed: Insufficient STRK balance for gas fees or network issue. Please check your wallet balance.');
      } else if (error.toString().includes('no active session')) {
        throw new Error('No active crafting session found. Please start a new crafting session first.');
      } else {
        throw new Error(`Failed to progress craft: ${error}`);
      }
    }
  }

  /**
   * Cancel crafting
   */
  async cancelCrafting(nftTokenId: string, aegisAccount: any): Promise<{ txHash: string }> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    // Check if contract address is valid
    if (!isValidContractAddress(this.contractAddress)) {
      throw new Error('Drug Crafting contract not deployed yet. Please deploy the contract first.');
    }

    try {
      console.log('Canceling crafting with Aegis:', nftTokenId);
      
      // Convert u256 to low and high
      const tokenId = BigInt(nftTokenId);
      const tokenIdLow = (tokenId & BigInt('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')).toString();
      const tokenIdHigh = (tokenId >> BigInt(128)).toString();
      
      const calldata = [
        tokenIdLow,
        tokenIdHigh
      ];

      const result = await aegisAccount.execute(
        this.contractAddress,
        'cancel_crafting',
        calldata
      );

      console.log('Cancel crafting transaction result:', result);
      
      return {
        txHash: result.transaction_hash
      };
    } catch (error) {
      console.error('Error canceling crafting with Aegis:', error);
      throw new Error(`Failed to cancel crafting: ${error}`);
    }
  }

  /**
   * Get information of a crafting session
   */
  async getCraftingSession(nftTokenId: string, aegisAccount?: any): Promise<CraftingSession | null> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    // Check if contract address is valid
    if (!isValidContractAddress(this.contractAddress)) {
      console.warn('Drug Crafting contract not deployed yet, returning null session');
      return null;
    }

    try {
      console.log('Getting crafting session with Aegis:', nftTokenId);
      
      // Convert u256 to low and high for the input parameter
      const tokenId = BigInt(nftTokenId);
      const tokenIdLow = (tokenId & BigInt('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')).toString();
      const tokenIdHigh = (tokenId >> BigInt(128)).toString();
      
      const result = await aegisAccount.call(
        this.contractAddress,
        'get_crafting_session',
        [tokenIdLow, tokenIdHigh]
      );

      console.log('Get crafting session result:', result);
      
      if (result && Array.isArray(result) && result.length >= 7) {
        // u256 se compone de low y high
        const nft_token_id_low = result[0];
        const nft_token_id_high = result[1];
        const nft_token_id = (BigInt(nft_token_id_high) << BigInt(128)) | BigInt(nft_token_id_low);
        
        const drug_name = result[2]; // Simplified for short strings
        
        // Verify if there is an active session
        // If drug_name is "0x0" or "0", there is no active session
        const hasActiveSession = drug_name !== '0x0' && drug_name !== '0' && 
                                result[3] !== '0x0' && result[3] !== '0'; // total_steps_required
        
        if (!hasActiveSession) {
          console.log('No active session detected - all fields are zero');
          return null;
        }
        
        return {
          nft_token_id: nft_token_id.toString(),
          drug_name: drug_name,
          total_steps_required: Number(result[3]),
          steps_completed: Number(result[4]),
          started_timestamp: Number(result[5]),
          last_progress_timestamp: Number(result[6]),
          is_active: Number(result[7]) === 1
        };
      }
      
      return null; // No active session
    } catch (error) {
      console.error('Error getting crafting session with Aegis:', error);
      // If there is no active session, the contract may throw an error
      console.warn('Returning null session due to contract error');
      return null;
    }
  }


  /**
   * Calculate crafting progress
   */
  calculateCraftingProgress(session: CraftingSession): CraftingProgress {
    const progress_percentage = session.total_steps_required > 0 
      ? (session.steps_completed / session.total_steps_required) * 100 
      : 0;

    const time_elapsed = Date.now() - session.started_timestamp;
    const time_elapsed_minutes = time_elapsed / (1000 * 60);

    // Estimate time remaining based on progress
    const estimated_time_remaining = progress_percentage > 0 
      ? (time_elapsed_minutes / progress_percentage) * (100 - progress_percentage)
      : 0;

    const time_since_last_progress = Date.now() - session.last_progress_timestamp;
    const next_step_available = time_since_last_progress >= 5 * 60 * 1000; // 5 minutes

    return {
      session,
      progress_percentage: Math.round(progress_percentage),
      time_elapsed: Math.round(time_elapsed_minutes),
      estimated_time_remaining: Math.round(estimated_time_remaining),
      next_step_available
    };
  }

  /**
   * Get player's crafted drugs
   */
  async getPlayerDrugs(nftTokenId: string, aegisAccount: any): Promise<number[]> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    // Check if contract address is valid
    if (!isValidContractAddress(this.contractAddress)) {
      console.warn('Drug Crafting contract not deployed yet, returning empty drug list');
      return [];
    }

    try {
      console.log('Getting player drugs with Aegis:', nftTokenId);
      
      // Convert u256 to low and high
      const tokenId = BigInt(nftTokenId);
      const tokenIdLow = (tokenId & BigInt('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')).toString();
      const tokenIdHigh = (tokenId >> BigInt(128)).toString();
      
      const result = await aegisAccount.call(
        this.contractAddress,
        'get_player_drugs',
        [tokenIdLow, tokenIdHigh]
      );

      console.log('Get player drugs result:', result);
      
      if (result && Array.isArray(result)) {
        return result.map(id => Number(id));
      }
      
      return [];
    } catch (error) {
      console.error('Error getting player drugs with Aegis:', error);
      console.warn('Returning empty drug list due to contract error');
      return [];
    }
  }

  /**
   * Get drug information by ID
   */
  async getDrug(drugId: number, aegisAccount: any): Promise<any> {
    if (!aegisAccount) {
      throw new Error('Aegis account not provided');
    }

    // Check if contract address is valid
    if (!isValidContractAddress(this.contractAddress)) {
      console.warn('Drug Crafting contract not deployed yet, returning null drug info');
      return null;
    }

    try {
      console.log('Getting drug with Aegis:', drugId);
      
      const result = await aegisAccount.call(
        this.contractAddress,
        'get_drug',
        [drugId.toString()]
      );

      console.log('Get drug result:', result);
      
      if (result && Array.isArray(result) && result.length >= 6) {
        return {
          id: Number(result[0]),
          name: result[1],
          rarity: result[2],
          purity: Number(result[3]),
          effects: result[4],
          created_timestamp: Number(result[5])
        };
      }
      
      return null;
    } catch (error) {
      console.error('Error getting drug with Aegis:', error);
      console.warn('Returning null drug info due to contract error');
      return null;
    }
  }

  /**
   * Format time in minutes to a readable string
   */
  formatTime(minutes: number): string {
    if (minutes < 60) {
      return `${minutes}m`;
    }
    
    const hours = Math.floor(minutes / 60);
    const remainingMinutes = minutes % 60;
    
    if (remainingMinutes === 0) {
      return `${hours}h`;
    }
    
    return `${hours}h ${remainingMinutes}m`;
  }
}

// Singleton instance of the service
export const drugCraftingService = new DrugCraftingService();
