/**
 * Drug Crafting Context
 * Context to manage the global state of the Drug Crafting System
 */

import React, { createContext, useContext, useReducer, useEffect, ReactNode } from 'react';
import { 
  CraftingState, 
  CraftingSession, 
  StartCraftingData,
  CraftingProgress,
  CraftingTransaction,
  CraftingAction,
  DrugInfo
} from '../types/drug-crafting';
import { drugCraftingService } from '../services/DrugCrafting.service';
import { useAegis } from '@cavos/aegis';

// Initial state
const initialState: CraftingState = {
  activeSession: null,
  transactions: [],
  loading: false,
  error: null,
  playerDrugs: [],
  drugDetails: {}
};

// Action types
type CraftingActionType = 
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_ERROR'; payload: string | null }
  | { type: 'SET_ACTIVE_SESSION'; payload: CraftingSession | null }
  | { type: 'ADD_TRANSACTION'; payload: CraftingTransaction }
  | { type: 'UPDATE_TRANSACTION'; payload: { hash: string; status: 'confirmed' | 'failed' } }
  | { type: 'SET_PLAYER_DRUGS'; payload: number[] }
  | { type: 'SET_DRUG_DETAILS'; payload: { drugId: number; details: DrugInfo } }
  | { type: 'CLEAR_ERROR' };

// Reducer function
function craftingReducer(state: CraftingState, action: CraftingActionType): CraftingState {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    
    case 'SET_ERROR':
      return { ...state, error: action.payload, loading: false };
    
    case 'SET_ACTIVE_SESSION':
      return { ...state, activeSession: action.payload };
    
    case 'ADD_TRANSACTION':
      return { 
        ...state, 
        transactions: [action.payload, ...state.transactions]
      };
    
    case 'UPDATE_TRANSACTION':
      return {
        ...state,
        transactions: state.transactions.map(tx => 
          tx.hash === action.payload.hash 
            ? { ...tx, status: action.payload.status }
            : tx
        )
      };
    
    case 'SET_PLAYER_DRUGS':
      return { ...state, playerDrugs: action.payload };
    
    case 'SET_DRUG_DETAILS':
      return {
        ...state,
        drugDetails: {
          ...state.drugDetails,
          [action.payload.drugId]: action.payload.details
        }
      };
    
    case 'CLEAR_ERROR':
      return { ...state, error: null };
    
    default:
      return state;
  }
}

// Interface of the context
interface DrugCraftingContextType {
  state: CraftingState;
  
  // Main actions
  startCrafting: (data: StartCraftingData) => Promise<void>;
  progressCraft: (nftTokenId: string) => Promise<void>;
  cancelCrafting: (nftTokenId: string) => Promise<void>;
  
  // Query actions
  fetchActiveSession: (nftTokenId: string) => Promise<void>;
  fetchPlayerDrugs: (nftTokenId: string) => Promise<void>;
  fetchDrugDetails: (drugId: number) => Promise<void>;
  
  // Utilities
  getCraftingProgress: () => CraftingProgress | null;
  clearError: () => void;
  formatTime: (minutes: number) => string;
}

// Create context
const DrugCraftingContext = createContext<DrugCraftingContextType | undefined>(undefined);

// Provider Props
interface DrugCraftingProviderProps {
  children: ReactNode;
}

// Provider component
export function DrugCraftingProvider({ children }: DrugCraftingProviderProps) {
  const [state, dispatch] = useReducer(craftingReducer, initialState);
  const { aegisAccount } = useAegis();

  // Helper function to handle errors
  const handleError = (error: any, action: string) => {
    console.error(`Error in ${action}:`, error);
    
    let errorMessage = error.message || `Failed to ${action}`;
    
    // Handle specific error types
    if (errorMessage.includes('paymaster execution failed')) {
      errorMessage = 'Transaction failed due to paymaster error. Please ensure you have sufficient STRK tokens for gas fees.';
    } else if (errorMessage.includes('Transaction failed after')) {
      errorMessage = 'Transaction failed after multiple attempts. Please check your wallet balance and try again.';
    } else if (errorMessage.includes('AVNU')) {
      errorMessage = 'Payment service error. Please try again or ensure you have sufficient funds.';
    }
    
    dispatch({ type: 'SET_ERROR', payload: errorMessage });
  };

  // Helper function to add transaction
  const addTransaction = (action: CraftingAction, data: any, hash: string) => {
    const transaction: CraftingTransaction = {
      action,
      data,
      hash,
      status: 'pending',
      timestamp: Date.now()
    };
    dispatch({ type: 'ADD_TRANSACTION', payload: transaction });
  };

  // Start crafting
  const startCrafting = async (data: StartCraftingData): Promise<void> => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      dispatch({ type: 'CLEAR_ERROR' });

      const result = await drugCraftingService.startCrafting(data, aegisAccount);
      addTransaction(CraftingAction.START_CRAFTING, data, result.txHash);
      
      // Reload active session
      await fetchActiveSession(data.nft_token_id);
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      handleError(error, 'start crafting');
    }
  };

  // Progress in crafting
  const progressCraft = async (nftTokenId: string): Promise<void> => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      dispatch({ type: 'CLEAR_ERROR' });

      const result = await drugCraftingService.progressCraft(nftTokenId, aegisAccount);
      addTransaction(CraftingAction.PROGRESS_CRAFT, { nftTokenId }, result.txHash);
      
      // Reload active session
      await fetchActiveSession(nftTokenId);
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      handleError(error, 'progress craft');
    }
  };

  // Cancel crafting
  const cancelCrafting = async (nftTokenId: string): Promise<void> => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      dispatch({ type: 'CLEAR_ERROR' });

      const result = await drugCraftingService.cancelCrafting(nftTokenId, aegisAccount);
      addTransaction(CraftingAction.CANCEL_CRAFTING, { nftTokenId }, result.txHash);
      
      // Clear active session
      dispatch({ type: 'SET_ACTIVE_SESSION', payload: null });
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      handleError(error, 'cancel crafting');
    }
  };

  // Get active session
  const fetchActiveSession = async (nftTokenId: string): Promise<void> => {
    try {
      dispatch({ type: 'CLEAR_ERROR' });

      const session = await drugCraftingService.getCraftingSession(nftTokenId, aegisAccount);
      dispatch({ type: 'SET_ACTIVE_SESSION', payload: session });
    } catch (error) {
      handleError(error, 'fetch active session');
    }
  };

  // Get player's drugs
  const fetchPlayerDrugs = async (nftTokenId: string): Promise<void> => {
    try {
      dispatch({ type: 'CLEAR_ERROR' });

      const drugIds = await drugCraftingService.getPlayerDrugs(nftTokenId, aegisAccount);
      dispatch({ type: 'SET_PLAYER_DRUGS', payload: drugIds });
    } catch (error) {
      handleError(error, 'fetch player drugs');
    }
  };

  // Get drug details
  const fetchDrugDetails = async (drugId: number): Promise<void> => {
    try {
      dispatch({ type: 'CLEAR_ERROR' });

      const drugDetails = await drugCraftingService.getDrug(drugId, aegisAccount);
      if (drugDetails) {
        dispatch({ type: 'SET_DRUG_DETAILS', payload: { drugId, details: drugDetails } });
      }
    } catch (error) {
      handleError(error, 'fetch drug details');
    }
  };


  // Get crafting progress
  const getCraftingProgress = (): CraftingProgress | null => {
    if (!state.activeSession) return null;
    return drugCraftingService.calculateCraftingProgress(state.activeSession);
  };


  // Clear error
  const clearError = () => {
    dispatch({ type: 'CLEAR_ERROR' });
  };

  // Format time
  const formatTime = (minutes: number): string => {
    return drugCraftingService.formatTime(minutes);
  };

  const contextValue: DrugCraftingContextType = {
    state,
    startCrafting,
    progressCraft,
    cancelCrafting,
    fetchActiveSession,
    fetchPlayerDrugs,
    fetchDrugDetails,
    getCraftingProgress,
    clearError,
    formatTime
  };

  return (
    <DrugCraftingContext.Provider value={contextValue}>
      {children}
    </DrugCraftingContext.Provider>
  );
}

// Hook to use the context
export function useDrugCrafting(): DrugCraftingContextType {
  const context = useContext(DrugCraftingContext);
  if (context === undefined) {
    throw new Error('useDrugCrafting must be used within a DrugCraftingProvider');
  }
  return context;
}
