use dosis_game::models::player::{PlayerAssert};
use dosis_game::models::drug::{DrugAssert};
use dosis_game::models::recipe::{RecipeAssert};
use dosis_game::types::drug_type::{DrugRarity};
use dosis_game::types::recipe::{Ingredient, CraftingResult};
use dosis_game::constants;

#[cfg(test)]
mod tests {
    use super::{
        PlayerAssert, DrugAssert, RecipeAssert, DrugRarity, 
        Ingredient, CraftingResult, constants
    };

    #[test]
    #[available_gas(20000000)]
    fn test_ingredient_creation() {
        let ingredient = Ingredient {
            name: 'Test Ingredient',
            quantity: 100,
            purity: 80
        };

        assert(ingredient.name == 'Test Ingredient', 'Ingredient name should match');
        assert(ingredient.quantity == 100, 'Quantity should be 100');
        assert(ingredient.purity == 80, 'Ingredient purity should be 80');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_crafting_result_types() {
        let critical_failure = CraftingResult::CriticalFailure;
        let failure = CraftingResult::Failure;
        let success = CraftingResult::Success;
        let critical_success = CraftingResult::CriticalSuccess;

        assert(critical_failure == CraftingResult::CriticalFailure, 'CriticalFailure should match');
        assert(failure == CraftingResult::Failure, 'Failure should match');
        assert(success == CraftingResult::Success, 'Success should match');
        assert(critical_success == CraftingResult::CriticalSuccess, 'CriticalSuccess should match');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_rarity_comparison() {
        let common = DrugRarity::Common;
        let legendary = DrugRarity::Legendary;

        assert(common == DrugRarity::Common, 'Drug should be common');
        assert(legendary == DrugRarity::Legendary, 'Drug should be legendary');
        assert(common != legendary, 'Common != legendary');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_constants_usage() {
        // Test that constants are properly defined
        assert(constants::MIN_RECIPE_DIFFICULTY == 1_u8, 'MIN_DIFF should be 1');
        assert(constants::MAX_RECIPE_DIFFICULTY == 10_u8, 'MAX_DIFF should be 10');
        assert(constants::BASE_SUCCESS_RATE == 50_u8, 'BASE_RATE should be 50');
        assert(constants::MAX_SUCCESS_RATE == 95_u8, 'MAX_RATE should be 95');
        assert(constants::MIN_SUCCESS_RATE == 5_u8, 'MIN_RATE should be 5');
        assert(constants::MAX_PURITY == 100_u8, 'MAX_PURITY should be 100');
        assert(constants::MIN_PURITY == 0_u8, 'MIN_PURITY should be 0');
        assert(constants::LEVEL_UP_REPUTATION_BONUS == 10_u8, 'REP_BONUS should be 10');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_rarity_multipliers() {
        assert(constants::COMMON_RARITY_MULTIPLIER == 1_u8, 'COMMON should be 1');
        assert(constants::UNCOMMON_RARITY_MULTIPLIER == 2_u8, 'UNCOMMON should be 2');
        assert(constants::RARE_RARITY_MULTIPLIER == 5_u8, 'RARE should be 5');
        assert(constants::EPIC_RARITY_MULTIPLIER == 10_u8, 'EPIC should be 10');
        assert(constants::LEGENDARY_RARITY_MULTIPLIER == 25_u8, 'LEGENDARY should be 25');
    }
}
