use dosis_game::models::crafting::CraftingSession;

#[starknet::interface]
pub trait IDrugCrafting<T> {
    fn start_crafting(
        ref self: T,
        nft_token_id: u256,
        name: ByteArray,
        base_ingredients: Array<(u32, u32)>,
        drug_ingredient_ids: Array<u32>,
    );
    fn progress_craft(ref self: T, nft_token_id: u256);
    fn cancel_crafting(ref self: T, nft_token_id: u256);
    fn get_crafting_session(self: @T, nft_token_id: u256) -> CraftingSession;
}

#[dojo::contract]
pub mod drug_crafting_system {
    use starknet::{get_block_timestamp, get_caller_address};
    use dojo::model::ModelStorage;
    use crate::interfaces::dosis_nft::{IDosisNFTDispatcher, IDosisNFTDispatcherTrait};
    use crate::models::nft::DrugRarity;
    use crate::models::crafting::{CraftingSession, AssertTrait};
    use crate::constants::{NFT_CONTRACTS, NAMESPACE};

    mod Errors {
        pub const NOT_OWNER: felt252 = 'Not owner';
        pub const CHARACTER_NOT_ACTIVE: felt252 = 'Character not active';
        pub const INSUFFICIENT_BASE_INGREDIENT: felt252 = 'Insufficient base ingredient';
        pub const NOT_DRUG_OWNER: felt252 = 'Not drug owner';
        pub const DRUG_INGREDIENT_LOCKED: felt252 = 'Drug ingredient is locked';
        pub const ALREADY_CRAFTING: felt252 = 'Already crafting';
        pub const NO_ACTIVE_CRAFTING: felt252 = 'No active crafting session';
        pub const CRAFTING_COMPLETED: felt252 = 'Crafting already completed';
    }

    #[derive(Drop, Serde, Copy)]
    pub enum CraftingResult {
        CriticalFailure,
        Failure,
        Success,
        CriticalSuccess,
    }

    #[abi(embed_v0)]
    impl DrugCraftingImpl of super::IDrugCrafting<ContractState> {
        fn start_crafting(
            ref self: ContractState,
            nft_token_id: u256,
            name: ByteArray,
            base_ingredients: Array<(u32, u32)>,
            drug_ingredient_ids: Array<u32>,
        ) {
            let mut world = self.world(NAMESPACE());

            // Check if already crafting
            let existing_session: CraftingSession = world.read_model(nft_token_id);
            assert(!existing_session.is_active, Errors::ALREADY_CRAFTING);
            // Get NFT contract
            let nft_contract = IDosisNFTDispatcher {
                contract_address: NFT_CONTRACTS()
            };

            // Get character stats
            let character_stats = nft_contract.get_character_stats(nft_token_id);
            assert(character_stats.owner == get_caller_address(), Errors::NOT_OWNER);
            assert(character_stats.is_active, Errors::CHARACTER_NOT_ACTIVE);

            // Validate base ingredients
            let mut i: u32 = 0;
            while i < base_ingredients.len() {
                let (ingredient_id, required_quantity) = *base_ingredients.at(i);
                let available_quantity = nft_contract.get_character_ingredient(nft_token_id, ingredient_id);
                assert(available_quantity >= required_quantity, Errors::INSUFFICIENT_BASE_INGREDIENT);
                i += 1;
            }

            // Validate drug ingredients (not locked)
            let mut j: u32 = 0;
            while j < drug_ingredient_ids.len() {
                let drug_id = *drug_ingredient_ids.at(j);
                let drug = nft_contract.get_drug(drug_id);
                assert(drug.owner_token_id == nft_token_id, Errors::NOT_DRUG_OWNER);
                assert(!drug.is_locked, Errors::DRUG_INGREDIENT_LOCKED);
                j += 1;
            }

            // Calculate crafting success (placeholder)
            // TODO: Implement actual crafting logic with success rate
            let _success_rate = calculate_success_rate(character_stats.level, 10);
            // let _crafting_result = simulate_crafting(_success_rate);

            // Consume ingredients
            let mut k: u32 = 0;
            while k < base_ingredients.len() {
                let (ingredient_id, quantity) = *base_ingredients.at(k);
                nft_contract.consume_ingredient(nft_token_id, ingredient_id, quantity);
                k += 1;
            }

            // Consume drug ingredients
            let mut l: u32 = 0;
            while l < drug_ingredient_ids.len() {
                let drug_id = *drug_ingredient_ids.at(l);
                nft_contract.consume_drug(drug_id);
                l += 1;
            }

            // Calculate total steps required for this craft
            let total_steps = calculate_total_steps(
                @base_ingredients,
                @drug_ingredient_ids,
                character_stats.level
            );

            // Create crafting session
            let current_time = get_block_timestamp();
            let session = CraftingSession {
                nft_token_id,
                drug_name: name,
                total_steps_required: total_steps,
                steps_completed: 0,
                started_timestamp: current_time,
                last_progress_timestamp: current_time,
                is_active: true,
            };

            world.write_model(@session);
        }

        fn progress_craft(ref self: ContractState, nft_token_id: u256) {
            let mut world = self.world(NAMESPACE());

            // Get crafting session
            let mut session: CraftingSession = world.read_model(nft_token_id);
            session.assert_active();
            session.assert_not_completed();

            // Get NFT contract
            let nft_contract = IDosisNFTDispatcher { contract_address: NFT_CONTRACTS() };

            // Verify ownership
            let character_stats = nft_contract.get_character_stats(nft_token_id);
            assert(character_stats.owner == get_caller_address(), Errors::NOT_OWNER);

            // Increment progress
            session.steps_completed += 1;
            session.last_progress_timestamp = get_block_timestamp();

            // Check if crafting is complete
            if session.steps_completed >= session.total_steps_required {
                // Complete the craft
                self._complete_craft(ref world, ref session, nft_contract);
            } else {
                // Save progress
                world.write_model(@session);
            }
        }

        fn cancel_crafting(ref self: ContractState, nft_token_id: u256) {
            let mut world = self.world(NAMESPACE());

            // Get crafting session
            let mut session: CraftingSession = world.read_model(nft_token_id);
            session.assert_active();

            // Get NFT contract
            let nft_contract = IDosisNFTDispatcher { contract_address: NFT_CONTRACTS() };

            // Verify ownership
            let character_stats = nft_contract.get_character_stats(nft_token_id);
            assert(character_stats.owner == get_caller_address(), Errors::NOT_OWNER);

            // Deactivate session
            session.is_active = false;
            world.write_model(@session);
        }

        fn get_crafting_session(self: @ContractState, nft_token_id: u256) -> CraftingSession {
            let world = self.world(NAMESPACE());
            world.read_model(nft_token_id)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _complete_craft(
            ref self: ContractState,
            ref world: dojo::world::WorldStorage,
            ref session: CraftingSession,
            nft_contract: IDosisNFTDispatcher,
        ) {
            let nft_token_id = session.nft_token_id;
            let character_stats = nft_contract.get_character_stats(nft_token_id);

            // Calculate crafting success
            let _success_rate = calculate_success_rate(character_stats.level, 10);
            let crafting_result = CraftingResult::Success; // TODO: Use simulate_crafting

            match crafting_result {
                CraftingResult::Success | CraftingResult::CriticalSuccess => {
                    let purity: u8 = 75;
                    let rarity = DrugRarity::Base;
                    let reputation_reward = calculate_reputation_reward(rarity, purity);
                    let cash_reward = calculate_cash_reward(rarity, purity);

                    // Create drug
                    nft_contract.mint_drug(
                        nft_token_id,
                        session.drug_name.clone(),
                        rarity,
                        reputation_reward,
                        cash_reward
                    );

                    // Calculate gains
                    let exp_gain = calculate_experience_gain(100, crafting_result, character_stats.level);
                    let rep_gain = calculate_reputation_gain(rarity, purity);

                    // Update character stats
                    nft_contract.update_character_stats(
                        nft_token_id,
                        0,
                        0,
                        exp_gain,
                        rep_gain,
                        true,
                    );
                },
                CraftingResult::Failure | CraftingResult::CriticalFailure => {
                    nft_contract.update_character_stats(
                        nft_token_id,
                        0,
                        0,
                        1,
                        0,
                        false,
                    );
                },
            };

            // Deactivate session
            session.is_active = false;
            world.write_model(@session);
        }
    }

    // Helper functions
    fn calculate_success_rate(player_level: u8, recipe_difficulty: u8) -> u8 {
        let base_rate: u8 = 50;
        let level_bonus = player_level * 5;
        let difficulty_penalty = recipe_difficulty * 3;

        let rate = base_rate + level_bonus - difficulty_penalty;
        if rate > 95 {
            95
        } else if rate < 10 {
            10
        } else {
            rate
        }
    }

    fn simulate_crafting(success_rate: u8) -> CraftingResult {
        let random_value = get_block_timestamp() % 100;

        if random_value < 2 {
            CraftingResult::CriticalFailure
        } else if random_value < 20 {
            CraftingResult::Failure
        } else if random_value < success_rate.into() {
            CraftingResult::Success
        } else if random_value >= 95 {
            CraftingResult::CriticalSuccess
        } else {
            CraftingResult::Failure
        }
    }

    fn get_rarity_from_recipe(recipe_rarity: felt252) -> DrugRarity {
        // Convert felt252 recipe rarity to DrugRarity enum
        // This is a placeholder - adjust based on your actual rarity encoding
        DrugRarity::Base
    }

    fn calculate_reputation_reward(rarity: DrugRarity, purity: u8) -> u32 {
        let base_reward = match rarity {
            DrugRarity::Base => 10,
            DrugRarity::Common => 25,
            DrugRarity::Rare => 50,
            DrugRarity::UltraRare => 100,
            DrugRarity::Legendary => 200,
        };

        let purity_bonus = (purity / 10).into();
        base_reward + purity_bonus
    }

    fn calculate_cash_reward(rarity: DrugRarity, purity: u8) -> u32 {
        let base_reward = match rarity {
            DrugRarity::Base => 20,
            DrugRarity::Common => 50,
            DrugRarity::Rare => 100,
            DrugRarity::UltraRare => 200,
            DrugRarity::Legendary => 500,
        };

        let purity_bonus = (purity / 5).into();
        base_reward + purity_bonus
    }

    fn calculate_experience_gain(base_exp: u16, result: CraftingResult, player_level: u8) -> u16 {
        let level_penalty = player_level.into() * 2;

        match result {
            CraftingResult::CriticalSuccess => base_exp * 2 - level_penalty,
            CraftingResult::Success => base_exp - level_penalty,
            CraftingResult::Failure => base_exp / 4,
            CraftingResult::CriticalFailure => 1,
        }
    }

    fn calculate_reputation_gain(rarity: DrugRarity, purity: u8) -> u16 {
        let rarity_multiplier = match rarity {
            DrugRarity::Base => 1,
            DrugRarity::Common => 2,
            DrugRarity::Rare => 3,
            DrugRarity::UltraRare => 5,
            DrugRarity::Legendary => 10,
        };

        let purity_bonus = (purity / 10).into();
        let base_rep: u16 = 5;
        base_rep * rarity_multiplier + purity_bonus
    }

    fn calculate_total_steps(
        base_ingredients: @Array<(u32, u32)>,
        drug_ingredient_ids: @Array<u32>,
        player_level: u8,
    ) -> u32 {
        // TODO: Implement logic based on:
        // - Number and quantity of base ingredients
        // - Number of drug ingredients
        // - Player level (higher level = fewer steps needed)
        // - Recipe complexity
        // For now, return a fixed value
        100
    }
}
