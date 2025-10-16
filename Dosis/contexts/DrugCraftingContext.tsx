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
  CraftingAction
} from '../types/drug-crafting';
import { drugCraftingService } from '../services/DrugCrafting.service';
import { useAegis } from '@cavos/aegis';

// Initial state
const initialState: CraftingState = {
  activeSession: null,
  transactions: [],
  loading: false,
  error: null
};

// Action types
type CraftingActionType = 
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_ERROR'; payload: string | null }
  | { type: 'SET_ACTIVE_SESSION'; payload: CraftingSession | null }
  | { type: 'ADD_TRANSACTION'; payload: CraftingTransaction }
  | { type: 'UPDATE_TRANSACTION'; payload: { hash: string; status: 'confirmed' | 'failed' } }
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
    dispatch({ type: 'SET_ERROR', payload: error.message || `Failed to ${action}` });
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
