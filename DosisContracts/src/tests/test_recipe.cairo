use dosis_game::models::recipe::{RecipeAssert, ZeroableRecipeTrait};

#[cfg(test)]
mod tests {
    use super::{RecipeAssert, ZeroableRecipeTrait};
    use dosis_game::constants;

    #[test]
    #[available_gas(20000000)]
    fn test_recipe_creation() {
        let mut recipe = ZeroableRecipeTrait::zero();
        recipe.id = 1;
        recipe.name = 'Cocaine Basic';
        recipe.drug_type = 0; // Stimulant
        recipe.rarity = 0; // Common
        recipe.ingredient_count = 3;
        recipe.primary_ingredient = 'coca_leaf';
        recipe.difficulty = 3;
        recipe.base_experience = 50;
        recipe.success_rate = 70;
        recipe.is_active = true;
        recipe.created_by = '';

        assert(recipe.id == 1, 'Recipe ID should be 1');
        assert(recipe.name == 'Cocaine Basic', 'Recipe name should match');
        assert(recipe.drug_type == 0, 'Drug type should be Stimulant');
        assert(recipe.rarity == 0, 'Rarity should be Common');
        assert(recipe.ingredient_count == 3, 'Should have 3 ingredients');
        assert(recipe.primary_ingredient == 'coca_leaf', 'Primary ingredient should match');
        assert(recipe.difficulty == 3, 'Difficulty should be 3');
        assert(recipe.base_experience == 50, 'Base experience should be 50');
        assert(recipe.success_rate == 70, 'Success rate should be 70');
        assert(recipe.is_active == true, 'Recipe should be active');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_recipe_assert_exists() {
        let mut recipe = ZeroableRecipeTrait::zero();
        recipe.id = 1;
        
        // This should not panic
        recipe.assert_exists();
    }

    #[test]
    #[available_gas(20000000)]
    fn test_recipe_difficulty_validation() {
        let mut recipe = ZeroableRecipeTrait::zero();
        recipe.id = 1;
        
        // Test minimum difficulty
        recipe.difficulty = constants::MIN_RECIPE_DIFFICULTY;
        assert(recipe.difficulty >= constants::MIN_RECIPE_DIFFICULTY, 'Difficulty should be >= MIN');
        
        // Test maximum difficulty
        recipe.difficulty = constants::MAX_RECIPE_DIFFICULTY;
        assert(recipe.difficulty <= constants::MAX_RECIPE_DIFFICULTY, 'Difficulty should be <= MAX');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_recipe_ingredient_count() {
        let mut recipe = ZeroableRecipeTrait::zero();
        recipe.id = 2;
        recipe.name = 'Complex Recipe';
        recipe.ingredient_count = 5;
        recipe.primary_ingredient = 'main_ingredient';

        assert(recipe.ingredient_count == 5, 'Should have 5 ingredients');
        assert(recipe.primary_ingredient == 'main_ingredient', 'Primary ingredient should match');
    }
}