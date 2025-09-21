use dosis_game::models::player::{Player, PlayerAssert};
use dosis_game::models::drug::{Drug, DrugAssert, DrugInventory};
use dosis_game::types::drug_type::{DrugType, DrugRarity, DrugState};
use dosis_game::types::recipe::{Recipe as RecipeType, CraftingResult};
use dosis_game::models::recipe::{Recipe, RecipeAssert};
use dosis_game::helpers::experience_utils::ExperienceCalculator;
use dosis_game::store::StoreTrait;
use starknet::{get_caller_address, get_block_timestamp};

#[starknet::interface]
pub trait IDrugCrafting<T> {
    fn spawn_player(ref self: T);
    fn craft_drug(ref self: T, recipe_id: u32, ingredients: Array<felt252>) -> u32;
    fn get_player_stats(ref self: T) -> (u8, u16, u32, u32, u32, u16);
    fn get_drug(ref self: T, drug_id: u32) -> Drug;
    fn get_player_drugs(ref self: T) -> Array<u32>;
}

#[dojo::contract]
pub mod drug_crafting_system {
    use super::{
        Player, PlayerAssert, Drug, DrugAssert, DrugInventory, 
        DrugType, DrugRarity, DrugState, Recipe, CraftingResult,
        ExperienceCalculator, StoreTrait, IDrugCrafting
    };
    use starknet::{get_caller_address, get_block_timestamp};
    use dojo::model::{ModelStorage};
    use dojo::world::{WorldStorage, WorldStorageTrait};

    #[storage]
    struct Storage {
        drug_counter: u256,
        recipe_counter: u256,
    }

    // Constructor
    fn dojo_init(ref self: ContractState) {
        self.drug_counter.write(1);
        self.recipe_counter.write(1);
    }

    #[abi(embed_v0)]
    impl DrugCraftingImpl of IDrugCrafting<ContractState> {
        fn spawn_player(ref self: ContractState) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let found = store.read_player();
            found.assert_not_exists();

            let player = Player {
                address: get_caller_address(),
                level: 1,
                experience: 0,
                total_drugs_created: 0,
                successful_crafts: 0,
                failed_crafts: 0,
                last_active_timestamp: get_block_timestamp(),
                creation_timestamp: get_block_timestamp(),
                reputation: 0,
            };

            store.write_player(player);

            // Initialize drug inventory
            let mut drug_ids = ArrayTrait::new();
            let inventory = DrugInventory {
                player: get_caller_address(),
                drug_ids,
                total_drugs: 0,
            };
            store.write_drug_inventory(inventory);
        }

        fn craft_drug(ref self: ContractState, recipe_id: u32, ingredients: Array<felt252>) -> u32 {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let mut player = store.read_player();
            player.assert_exists();

            // Get recipe from storage
            let recipe = store.read_recipe(recipe_id);
            recipe.assert_exists();
            
            // Calculate crafting success based on player level and recipe difficulty
            let success_rate = calculate_success_rate(player.level, recipe.difficulty);
            let crafting_result = simulate_crafting(success_rate);

            let drug_id = self.drug_counter.read();
            self.drug_counter.write(drug_id + 1);

            match crafting_result {
                CraftingResult::Success | CraftingResult::CriticalSuccess => {
                    // Create successful drug
                    let mut drug = Drug {
                        id: drug_id.try_into().unwrap(),
                        owner: get_caller_address(),
                        name: recipe.name,
                        drug_type: recipe.drug_type,
                        rarity: recipe.rarity,
                        state: DrugState::Refined,
                        purity: calculate_purity(crafting_result, recipe.difficulty),
                        quantity: 1,
                        creation_timestamp: get_block_timestamp(),
                        recipe_id,
                    };

                    // Award experience
                    let exp_gained = calculate_experience_gain(recipe, crafting_result, player.level);
                    player.experience += exp_gained;
                    player.total_drugs_created += 1;
                    player.successful_crafts += 1;
                    player.last_active_timestamp = get_block_timestamp();

                    // Check for level up
                    if ExperienceCalculator::should_level_up(player.level, player.experience) {
                        player.level += 1;
                        player.experience = ExperienceCalculator::remaining_exp_after_level_up(
                            player.level - 1, player.experience
                        );
                        // Award reputation for leveling up
                        player.reputation += 10;
                    }

                    // Award reputation based on drug quality
                    player.reputation += calculate_reputation_gain(drug.rarity, drug.purity);

                    store.write_drug(drug);
                    store.write_player(player);

                    // Update inventory
                    let mut inventory = store.read_drug_inventory();
                    inventory.drug_ids.append(drug_id.try_into().unwrap());
                    inventory.total_drugs += 1;
                    store.write_drug_inventory(inventory);

                    drug_id.try_into().unwrap()
                },
                CraftingResult::Failure | CraftingResult::CriticalFailure => {
                    // Failed crafting
                    player.failed_crafts += 1;
                    player.last_active_timestamp = get_block_timestamp();
                    
                    // Small experience gain even for failures
                    player.experience += 1;
                    
                    store.write_player(player);
                    0 // Return 0 for failed crafting
                }
            }
        }

        fn get_player_stats(ref self: ContractState) -> (u8, u16, u32, u32, u32, u16) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let player = store.read_player();
            player.assert_exists();

            (
                player.level,
                player.experience,
                player.total_drugs_created,
                player.successful_crafts,
                player.failed_crafts,
                player.reputation
            )
        }

        fn get_drug(ref self: ContractState, drug_id: u32) -> Drug {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let drug = store.read_drug(drug_id);
            drug.assert_exists();
            drug
        }

        fn get_player_drugs(ref self: ContractState) -> Array<u32> {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let inventory = store.read_drug_inventory();
            inventory.drug_ids
        }
    }

    // Helper functions

    fn calculate_success_rate(player_level: u8, recipe_difficulty: u8) -> u8 {
        let base_rate = 50;
        let level_bonus = player_level * 5;
        let difficulty_penalty = recipe_difficulty * 3;
        
        let rate = base_rate + level_bonus - difficulty_penalty;
        if rate > 95 { 95 } else if rate < 5 { 5 } else { rate }
    }

    fn simulate_crafting(success_rate: u8) -> CraftingResult {
        // Simplified random simulation
        let random_value = get_block_timestamp() % 100;
        
        if random_value < 2 {
            CraftingResult::CriticalFailure
        } else if random_value < 5 {
            CraftingResult::Failure
        } else if random_value < success_rate {
            CraftingResult::Success
        } else if random_value < success_rate + 5 {
            CraftingResult::CriticalSuccess
        } else {
            CraftingResult::Failure
        }
    }

    fn calculate_purity(result: CraftingResult, difficulty: u8) -> u8 {
        match result {
            CraftingResult::CriticalSuccess => 95 + (difficulty * 2),
            CraftingResult::Success => 70 + difficulty,
            CraftingResult::Failure => 30 + difficulty,
            CraftingResult::CriticalFailure => 10,
        }
    }

    fn calculate_experience_gain(recipe: Recipe, result: CraftingResult, player_level: u8) -> u16 {
        let base_exp = recipe.base_experience;
        let level_penalty = player_level * 2; // Higher level players get less exp
        
        match result {
            CraftingResult::CriticalSuccess => base_exp * 2 - level_penalty,
            CraftingResult::Success => base_exp - level_penalty,
            CraftingResult::Failure => base_exp / 4,
            CraftingResult::CriticalFailure => 1,
        }
    }

    fn calculate_reputation_gain(rarity: DrugRarity, purity: u8) -> u16 {
        let rarity_multiplier = match rarity {
            DrugRarity::Common => 1,
            DrugRarity::Uncommon => 2,
            DrugRarity::Rare => 5,
            DrugRarity::Epic => 10,
            DrugRarity::Legendary => 25,
        };
        
        let purity_bonus = purity / 10;
        rarity_multiplier + purity_bonus
    }
}
