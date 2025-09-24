use dosis_game::models::recipe::{RecipeAssert};

#[cfg(test)]
mod tests {
    use super::RecipeAssert;
    use dosis_game::types::drug_type::{DrugType, DrugRarity};
    use dosis_game::types::recipe::Ingredient;
    use dosis_game::constants;

    #[test]
    #[available_gas(20000000)]
    fn test_ingredient_creation() {
        let ingredient = Ingredient {
            name: 'Coca Leaves',
            quantity: 100,
            purity: 80
        };

        assert(ingredient.name == 'Coca Leaves', 'Ingredient name should match');
        assert(ingredient.quantity == 100, 'Quantity should be 100');
        assert(ingredient.purity == 80, 'Ingredient purity should be 80');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_type_comparison() {
        let stimulant = DrugType::Stimulant;
        let depressant = DrugType::Depressant;

        assert(stimulant == DrugType::Stimulant, 'Stimulant should match');
        assert(depressant == DrugType::Depressant, 'Depressant should match');
        assert(stimulant != depressant, 'Stimulant != depressant');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_rarity_comparison() {
        let common = DrugRarity::Common;
        let rare = DrugRarity::Rare;

        assert(common == DrugRarity::Common, 'Common should match');
        assert(rare == DrugRarity::Rare, 'Rare should match');
        assert(common != rare, 'Common should not equal rare');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_recipe_difficulty_validation() {
        // Test valid difficulty ranges
        assert(constants::MIN_RECIPE_DIFFICULTY == 1, 'MIN_DIFF should be 1');
        assert(constants::MAX_RECIPE_DIFFICULTY == 10, 'MAX_DIFF should be 10');
        
        // Test that difficulty 1 is valid
        let valid_difficulty = constants::MIN_RECIPE_DIFFICULTY;
        assert(valid_difficulty >= constants::MIN_RECIPE_DIFFICULTY, 'Difficulty 1 should be valid');
        assert(valid_difficulty <= constants::MAX_RECIPE_DIFFICULTY, 'Difficulty 1 should be valid');

        // Test that difficulty 10 is valid
        let max_difficulty = constants::MAX_RECIPE_DIFFICULTY;
        assert(max_difficulty >= constants::MIN_RECIPE_DIFFICULTY, 'Difficulty 10 should be valid');
        assert(max_difficulty <= constants::MAX_RECIPE_DIFFICULTY, 'Difficulty 10 should be valid');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_ingredient_validation() {
        let ingredient = Ingredient {
            name: 'Test Ingredient',
            quantity: 100,
            purity: 85
        };

        assert(ingredient.name == 'Test Ingredient', 'Ingredient name should match');
        assert(ingredient.quantity == 100, 'Quantity should be 100');
        assert(ingredient.purity == 85, 'Ingredient purity should be 85');
        assert(ingredient.purity >= constants::MIN_PURITY, 'Purity should be >= MIN_PURITY');
        assert(ingredient.purity <= constants::MAX_PURITY, 'Purity should be <= MAX_PURITY');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_multiple_ingredients_array() {
        let mut ingredients = ArrayTrait::new();
        ingredients.append(Ingredient { name: 'Ing1', quantity: 100, purity: 80 });
        ingredients.append(Ingredient { name: 'Ing2', quantity: 50, purity: 90 });
        ingredients.append(Ingredient { name: 'Ing3', quantity: 25, purity: 95 });
        let ingredients_span = ingredients.span();
        
        assert(ingredients_span.len() == 3, 'Should have 3 ingredients');
        
        let first_ingredient = *ingredients_span[0];
        assert(first_ingredient.quantity == 100, 'First qty should be 100');
        assert(first_ingredient.purity == 80, 'First purity should be 80');
    }
}
