/**
 * Drug Crafting System Types
 * Types to interact with the Drug Crafting System contract
 */

export interface CraftingSession {
  nft_token_id: string;
  drug_name: string;
  total_steps_required: number;
  steps_completed: number;
  started_timestamp: number;
  last_progress_timestamp: number;
  is_active: boolean;
}

export interface BaseIngredient {
  ingredient_id: number;
  quantity: number;
}

export interface DrugRecipe {
  id: number;
  name: string;
  description: string;
  difficulty: 'Easy' | 'Medium' | 'Hard' | 'Expert';
  base_ingredients: BaseIngredient[];
  drug_ingredient_ids: number[];
  estimated_time_minutes: number;
  success_rate: number;
  rarity: string;
  effects: string[];
}

export interface StartCraftingData {
  nft_token_id: string;
  name: string;
  base_ingredients: BaseIngredient[];
  drug_ingredient_ids: number[];
}

export interface CraftingProgress {
  session: CraftingSession;
  progress_percentage: number;
  time_elapsed: number;
  estimated_time_remaining: number;
  next_step_available: boolean;
}

export interface CraftingStats {
  total_sessions: number;
  successful_crafts: number;
  active_sessions: number;
  average_crafting_time: number;
  favorite_drug_type: string;
}

export enum CraftingAction {
  START_CRAFTING = 'start_crafting',
  PROGRESS_CRAFT = 'progress_craft',
  CANCEL_CRAFTING = 'cancel_crafting',
}

export interface CraftingTransaction {
  action: CraftingAction;
  data: any;
  hash?: string;
  status: 'pending' | 'confirmed' | 'failed';
  timestamp: number;
}

export interface CraftingState {
  activeSession: CraftingSession | null;
  transactions: CraftingTransaction[];
  loading: boolean;
  error: string | null;
  playerDrugs: number[];
  drugDetails: { [drugId: number]: DrugInfo };
}

export interface CraftingFilters {
  difficulty?: string[];
  ingredient_available?: boolean;
  estimated_time_max?: number;
}

export interface IngredientRequirement {
  ingredient_id: number;
  name: string;
  required_quantity: number;
  available_quantity: number;
  is_sufficient: boolean;
}

export interface CraftingValidation {
  can_start: boolean;
  missing_ingredients: IngredientRequirement[];
  total_cost: string;
  estimated_success_rate: number;
}

export interface DrugInfo {
  id: number;
  name: string;
  rarity: string;
  purity: number;
  effects: string;
  created_timestamp: number;
}
