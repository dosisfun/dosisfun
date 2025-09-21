use dosis_game::types::drug_type::{DrugType, DrugRarity};
use dosis_game::types::recipe::{Ingredient, Recipe as RecipeType};

#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct Recipe {
    #[key]
    pub id: u32,
    pub name: felt252,
    pub drug_type: DrugType,
    pub rarity: DrugRarity,
    pub ingredients: Array<Ingredient>,
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
        let mut empty_ingredients = ArrayTrait::new();
        Recipe {
            id: 0,
            name: '',
            drug_type: DrugType::Stimulant,
            rarity: DrugRarity::Common,
            ingredients: empty_ingredients,
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
    use super::{Recipe, DrugType, DrugRarity, Ingredient, ZeroableRecipeTrait};

    #[test]
    fn test_recipe_creation() {
        let mut ingredients = ArrayTrait::new();
        ingredients.append(Ingredient {
            name: 'coca_leaf',
            quantity: 5,
            purity: 90,
        });
        
        let recipe = Recipe {
            id: 1,
            name: 'cocaine_basic',
            drug_type: DrugType::Stimulant,
            rarity: DrugRarity::Common,
            ingredients,
            difficulty: 3,
            base_experience: 50,
            success_rate: 70,
            is_active: true,
            created_by: '0x123',
        };
        
        assert_eq!(recipe.id, 1, "Recipe ID should be 1");
        assert_eq!(recipe.name, 'cocaine_basic', "Recipe name should match");
        assert_eq!(recipe.difficulty, 3, "Difficulty should be 3");
        assert_eq!(recipe.base_experience, 50, "Base experience should be 50");
        assert_eq!(recipe.is_active, true, "Recipe should be active");
    }

    #[test]
    fn test_recipe_zero_initialization() {
        let zero_recipe: Recipe = ZeroableRecipeTrait::zero();
        
        assert_eq!(zero_recipe.id, 0, "Zero recipe ID should be 0");
        assert_eq!(zero_recipe.difficulty, 1, "Zero recipe difficulty should be 1");
        assert_eq!(zero_recipe.is_active, false, "Zero recipe should not be active");
    }
}
