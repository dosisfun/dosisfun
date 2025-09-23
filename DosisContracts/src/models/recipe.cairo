
use core::num::traits::zero::Zero;

#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct Recipe {
    #[key]
    pub id: u32,
    pub name: felt252,
    pub drug_type: felt252, 
    pub rarity: felt252,    
    pub ingredient_count: u8, // Number of ingredients
    pub primary_ingredient: felt252, // Name of the primary ingredient
    pub difficulty: u8, // 1-10
    pub base_experience: u16,
    pub success_rate: u8, // 0-100
    pub is_active: bool,
    pub created_by: felt252, // Creator address as felt252
}

#[generate_trait]
pub impl RecipeAssert of AssertTrait {
    #[inline(always)]
    fn assert_exists(self: Recipe) {
        assert(self.id > 0, 'Recipe: Does not exist');
    }

    #[inline(always)]
    fn assert_not_exists(self: Recipe) {
        assert(self.id == 0, 'Recipe: Already exists');
    }
}

pub impl ZeroableRecipeTrait of Zero<Recipe> {
    #[inline(always)]
    fn zero() -> Recipe {
        Recipe {
            id: 0,
            name: '',
            drug_type: 0, // Default to 0 (e.g., Stimulant)
            rarity: 0,    // Default to 0 (e.g., Common)
            ingredient_count: 0,
            primary_ingredient: '',
            difficulty: 1,
            base_experience: 10,
            success_rate: 50,
            is_active: false,
            created_by: '',
        }
    }

    #[inline(always)]
    fn is_zero(self: @Recipe) -> bool {
        *self.id == 0
    }

    #[inline(always)]
    fn is_non_zero(self: @Recipe) -> bool {
        !self.is_zero()
    }
}

#[cfg(test)]
mod tests {
    use super::{Recipe, ZeroableRecipeTrait};

    #[test]
    fn test_recipe_creation() {
        
        let recipe = Recipe {
            id: 1,
            name: 'cocaine_basic',
            drug_type: 0, // Default to 0 (e.g., Stimulant)
            rarity: 0,    // Default to 0 (e.g., Common)
            ingredient_count: 3,
            primary_ingredient: 'coca_leaf',
            difficulty: 3,
            base_experience: 50,
            success_rate: 70,
            is_active: true,
            created_by: '0x123',
        };
        
        assert(recipe.id == 1, 'Recipe ID should be 1');
        assert(recipe.name == 'cocaine_basic', 'Recipe name should match');
        assert(recipe.difficulty == 3, 'Difficulty should be 3');
        assert(recipe.base_experience == 50, 'Base experience should be 50');
        assert(recipe.is_active == true, 'Recipe should be active');
    }

    #[test]
    fn test_recipe_zero_initialization() {
        let zero_recipe: Recipe = ZeroableRecipeTrait::zero();
        
        assert(zero_recipe.id == 0, 'Zero recipe ID should be 0');
        assert(zero_recipe.difficulty == 1, 'Zero recipe difficulty is 1');
        assert(zero_recipe.is_active == false, 'Zero recipe not active');
    }
}
