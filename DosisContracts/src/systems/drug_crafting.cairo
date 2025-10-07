#[starknet::interface]
pub trait IDrugCrafting<T> {
    fn craft_drug(
        ref self: T,
        nft_token_id: u256,
        name: ByteArray,
        base_ingredients: Array<(u32, u32)>,
        drug_ingredient_ids: Array<u32>,
    );
}

#[dojo::contract]
pub mod drug_crafting_system {
    use starknet::{get_block_timestamp, get_caller_address};
    use crate::interfaces::dosis_nft::{IDosisNFTDispatcher, IDosisNFTDispatcherTrait};
    use crate::models::nft::DrugRarity;
    use crate::constants::NFT_CONTRACTS;

    mod Errors {
        pub const NOT_OWNER: felt252 = 'Not owner';
        pub const CHARACTER_NOT_ACTIVE: felt252 = 'Character not active';
        pub const INSUFFICIENT_BASE_INGREDIENT: felt252 = 'Insufficient base ingredient';
        pub const NOT_DRUG_OWNER: felt252 = 'Not drug owner';
        pub const DRUG_INGREDIENT_LOCKED: felt252 = 'Drug ingredient is locked';
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
        fn craft_drug(
            ref self: ContractState,
            nft_token_id: u256,
            name: ByteArray,
            base_ingredients: Array<(u32, u32)>,
            drug_ingredient_ids: Array<u32>,
        ) {
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

            // Calculate crafting success
            let _success_rate = calculate_success_rate(
                character_stats.level, 10,
            ); // TODO: Change to actual difficulty
            // let crafting_result = simulate_crafting(_success_rate);
            let crafting_result = CraftingResult::Success;

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

            match crafting_result {
                CraftingResult::Success |
                CraftingResult::CriticalSuccess => {
                    // TODO: Calculate purity based on ingredients and player level
                    // This should take into account:
                    // - Base ingredients quality
                    // - Drug ingredients purity (if using drugs as ingredients)
                    // - Player level bonus
                    // - Recipe difficulty
                    let purity: u8 = 75; // Placeholder

                    // Calculate rewards
                    let rarity = DrugRarity::Base; // TODO: Change to actual rarity
                    let reputation_reward = calculate_reputation_reward(rarity, purity);
                    let cash_reward = calculate_cash_reward(rarity, purity);

                    // Create drug in NFT contract
                    let drug_id = nft_contract
                        .mint_drug(nft_token_id, name, rarity, reputation_reward, cash_reward);

                    // Calculate experience gain
                    let exp_gain = calculate_experience_gain(
                        100, crafting_result, character_stats.level,
                    );
                    let rep_gain = calculate_reputation_gain(rarity, purity);

                    // Update character stats
                    nft_contract.update_character_stats(
                        nft_token_id,
                        0, // cash (not added directly on crafting)
                        0, // level (will be calculated in contract)
                        exp_gain,
                        rep_gain,
                        true, // craft_success
                    );
                    drug_id
                },
                CraftingResult::Failure |
                CraftingResult::CriticalFailure => {
                    // Update character stats with failure
                    nft_contract.update_character_stats(
                        nft_token_id,
                        0, // cash
                        0, // level
                        1, // minimal experience
                        0, // reputation
                        false, // craft_success
                    );
                    0
                },
            };
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
}
