/**
 * Black Market Context
 * Context to manage the global state of the Black Market System
 */

import React, { createContext, useContext, useReducer, useEffect, ReactNode } from 'react';
import { 
  BlackMarketState, 
  MarketListing, 
  ListingFormData,
  BuyDrugData,
  BuyIngredientData,
  BlackMarketFilters,
  BlackMarketTransaction,
  BlackMarketAction
} from '../types/black-market';
import { blackMarketService } from '../services/BlackMarket.service';
import { useAegis } from '@cavos/aegis';

// Initial state
const initialState: BlackMarketState = {
  listings: [],
  myListings: [],
  loading: false,
  error: null,
  transactions: []
};

// Action types
type BlackMarketActionType = 
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_ERROR'; payload: string | null }
  | { type: 'SET_LISTINGS'; payload: MarketListing[] }
  | { type: 'SET_MY_LISTINGS'; payload: MarketListing[] }
  | { type: 'ADD_TRANSACTION'; payload: BlackMarketTransaction }
  | { type: 'UPDATE_TRANSACTION'; payload: { hash: string; status: 'confirmed' | 'failed' } }
  | { type: 'CLEAR_ERROR' };

// Reducer function
function blackMarketReducer(state: BlackMarketState, action: BlackMarketActionType): BlackMarketState {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    
    case 'SET_ERROR':
      return { ...state, error: action.payload, loading: false };
    
    case 'SET_LISTINGS':
      return { ...state, listings: action.payload };
    
    case 'SET_MY_LISTINGS':
      return { ...state, myListings: action.payload };
    
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
interface BlackMarketContextType {
  state: BlackMarketState;
  
  // Main actions
  listDrug: (data: ListingFormData) => Promise<void>;
  cancelListing: (nftTokenId: string, listingId: number) => Promise<void>;
  buyDrug: (data: BuyDrugData) => Promise<void>;
  buyIngredient: (data: BuyIngredientData) => Promise<void>;
  
  // Query actions
  fetchListings: (filters?: BlackMarketFilters) => Promise<void>;
  fetchMyListings: (nftTokenId: string) => Promise<void>;
  fetchListing: (listingId: number) => Promise<MarketListing>;
  
  // Utilities
  clearError: () => void;
  formatPrice: (priceInWei: string) => string;
  parsePrice: (priceInEth: string) => string;
}

// Create context
const BlackMarketContext = createContext<BlackMarketContextType | undefined>(undefined);

// Provider props
interface BlackMarketProviderProps {
  children: ReactNode;
}

// Provider component
export function BlackMarketProvider({ children }: BlackMarketProviderProps) {
  const [state, dispatch] = useReducer(blackMarketReducer, initialState);
  const { aegisAccount } = useAegis();

  // Helper function to handle errors
  const handleError = (error: any, action: string) => {
    console.error(`Error in ${action}:`, error);
    dispatch({ type: 'SET_ERROR', payload: error.message || `Failed to ${action}` });
  };

  // Helper function to add transaction
  const addTransaction = (action: BlackMarketAction, data: any, hash: string) => {
    const transaction: BlackMarketTransaction = {
      action,
      data,
      hash,
      status: 'pending',
      timestamp: Date.now()
    };
    dispatch({ type: 'ADD_TRANSACTION', payload: transaction });
  };

  // List drug
  const listDrug = async (data: ListingFormData): Promise<void> => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      dispatch({ type: 'CLEAR_ERROR' });

      const result = await blackMarketService.listDrug(data, aegisAccount);
      addTransaction(BlackMarketAction.LIST_DRUG, data, result.txHash);
      
      // Reload my listings
      if (data.nft_token_id) {
        await fetchMyListings(data.nft_token_id);
      }
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      handleError(error, 'list drug');
    }
  };

  // Cancel listing
  const cancelListing = async (nftTokenId: string, listingId: number): Promise<void> => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      dispatch({ type: 'CLEAR_ERROR' });

      const result = await blackMarketService.cancelListing(nftTokenId, listingId, aegisAccount);
      addTransaction(BlackMarketAction.CANCEL_LISTING, { nftTokenId, listingId }, result.txHash);
      
      // Reload my listings
      await fetchMyListings(nftTokenId);
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      handleError(error, 'cancel listing');
    }
  };

  // Buy drug
  const buyDrug = async (data: BuyDrugData): Promise<void> => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      dispatch({ type: 'CLEAR_ERROR' });

      const result = await blackMarketService.buyDrug(data, aegisAccount);
      addTransaction(BlackMarketAction.BUY_DRUG, data, result.txHash);
      
      // Recargar listings activos
      await fetchListings();
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      handleError(error, 'buy drug');
    }
  };

  // Buy ingredient
  const buyIngredient = async (data: BuyIngredientData): Promise<void> => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      dispatch({ type: 'CLEAR_ERROR' });

      const result = await blackMarketService.buyIngredient(data, aegisAccount);
      addTransaction(BlackMarketAction.BUY_INGREDIENT, data, result.txHash);
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      handleError(error, 'buy ingredient');
    }
  };

  // Get active listings
  const fetchListings = async (filters?: BlackMarketFilters): Promise<void> => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      dispatch({ type: 'CLEAR_ERROR' });

      const listings = await blackMarketService.getActiveListings(filters, aegisAccount);
      dispatch({ type: 'SET_LISTINGS', payload: listings });
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      handleError(error, 'fetch listings');
    }
  };

  // Get my listings
  const fetchMyListings = async (nftTokenId: string): Promise<void> => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      dispatch({ type: 'CLEAR_ERROR' });

      const myListings = await blackMarketService.getSellerListings(nftTokenId, aegisAccount);
      dispatch({ type: 'SET_MY_LISTINGS', payload: myListings });
      
      dispatch({ type: 'SET_LOADING', payload: false });
    } catch (error) {
      handleError(error, 'fetch my listings');
    }
  };


  // Get specific listing
  const fetchListing = async (listingId: number): Promise<MarketListing> => {
    try {
      dispatch({ type: 'CLEAR_ERROR' });
      return await blackMarketService.getListing(listingId, aegisAccount);
    } catch (error) {
      handleError(error, 'fetch listing');
      throw error;
    }
  };

  // Clear error
  const clearError = () => {
    dispatch({ type: 'CLEAR_ERROR' });
  };

  // Format price
  const formatPrice = (priceInWei: string): string => {
    return blackMarketService.formatPrice(priceInWei);
  };

  // Parse price
  const parsePrice = (priceInEth: string): string => {
    return blackMarketService.parsePrice(priceInEth);
  };

  // Load initial data
  useEffect(() => {
    const loadInitialData = async () => {
      await fetchListings();
    };

    loadInitialData();
  }, []);

  const contextValue: BlackMarketContextType = {
    state,
    listDrug,
    cancelListing,
    buyDrug,
    buyIngredient,
    fetchListings,
    fetchMyListings,
    fetchListing,
    clearError,
    formatPrice,
    parsePrice
  };

  return (
    <BlackMarketContext.Provider value={contextValue}>
      {children}
    </BlackMarketContext.Provider>
  );
}

// Hook to use the context
export function useBlackMarket(): BlackMarketContextType {
  const context = useContext(BlackMarketContext);
  if (context === undefined) {
    throw new Error('useBlackMarket must be used within a BlackMarketProvider');
  }
  return context;
}
