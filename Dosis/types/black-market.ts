/**
 * Black Market System Types
 * Types to interact with the Black Market System contract
 */

export interface MarketListing {
  id: number;
  seller_nft_token_id: string;
  drug_id: number;
  price: string;
  is_active: boolean;
  listed_timestamp: number;
  sold_timestamp: number;
  buyer_nft_token_id: string;
}

export interface DrugInfo {
  id: number;
  name: string;
  description: string;
  rarity: string;
  effects: string[];
  base_price: string;
}

export interface IngredientInfo {
  id: number;
  name: string;
  description: string;
  price_per_unit: string;
  rarity: string;
}

export interface ListingFormData {
  nft_token_id: string;
  drug_id: number;
  price: string;
}

export interface BuyIngredientData {
  nft_token_id: string;
  ingredient_id: number;
  quantity: number;
}

export interface BuyDrugData {
  buyer_nft_token_id: string;
  listing_id: number;
}

export interface BlackMarketFilters {
  min_price?: string;
  max_price?: string;
  drug_types?: number[];
  active_only?: boolean;
}

export enum BlackMarketAction {
  LIST_DRUG = 'list_drug',
  CANCEL_LISTING = 'cancel_listing',
  BUY_DRUG = 'buy_drug',
  BUY_INGREDIENT = 'buy_ingredient',
}

export interface BlackMarketTransaction {
  action: BlackMarketAction;
  data: any;
  hash?: string;
  status: 'pending' | 'confirmed' | 'failed';
  timestamp: number;
}

export interface BlackMarketState {
  listings: MarketListing[];
  myListings: MarketListing[];
  loading: boolean;
  error: string | null;
  transactions: BlackMarketTransaction[];
}
