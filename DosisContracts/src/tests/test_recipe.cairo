use dosis_game::models::recipe::{RecipeAssert, ZeroableRecipeTrait};

#[cfg(test)]
mod tests {
    use super::{RecipeAssert, ZeroableRecipeTrait};
    use dosis_game::types::drug_type::{DrugType, DrugRarity};
    use dosis_game::types::recipe::Ingredient;
    use dosis_game::constants;

    #[test]
    #[available_gas(20000000)]
    fn test_recipe_creation() {
        let mut ingredients = ArrayTrait::new();
        ingredients.append(Ingredient { name: 'Coca Leaves', quantity: 100, purity: 80 });
        ingredients.append(Ingredient { name: 'Chemicals', quantity: 50, purity: 90 });
        let ingredients_span = ingredients.span();

        let mut recipe = ZeroableRecipeTrait::zero();
        recipe.id = 1;
        recipe.name = 'Cocaine Basic';
        recipe.drug_type = DrugType::Stimulant;
        recipe.rarity = DrugRarity::Common;
        recipe.ingredients = ingredients_span;
        recipe.difficulty = 3;
        recipe.base_experience = 50;
        recipe.success_rate = 70;
        recipe.is_active = true;
        recipe.created_by = '';

        assert(recipe.id == 1, 'Recipe ID should be 1');
        assert(recipe.name == 'Cocaine Basic', 'Recipe name should match');
        assert(recipe.drug_type == DrugType::Stimulant, 'Drug type should be Stimulant');
        assert(recipe.rarity == DrugRarity::Common, 'Rarity should be Common');
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
    fn test_ingredient_creation() {
        let ingredient = Ingredient {
            name: 'Test Ingredient',
            quantity: 100,
            purity: 85
        };

        assert(ingredient.name == 'Test Ingredient', 'Ingredient name should match');
        assert(ingredient.quantity == 100, 'Quantity should be 100');
        assert(ingredient.purity == 85, 'Purity should be 85');
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
    fn test_recipe_with_multiple_ingredients() {
        let mut ingredients = ArrayTrait::new();
        ingredients.append(Ingredient { name: 'Ingredient 1', quantity: 100, purity: 80 });
        ingredients.append(Ingredient { name: 'Ingredient 2', quantity: 50, purity: 90 });
        ingredients.append(Ingredient { name: 'Ingredient 3', quantity: 25, purity: 95 });
        let ingredients_span = ingredients.span();

        let mut recipe = ZeroableRecipeTrait::zero();
        recipe.id = 1;
        recipe.ingredients = ingredients_span;

        let recipe_ingredients = recipe.ingredients;
        assert(recipe_ingredients.len() == 3, 'Should have 3 ingredients');
    }
}
