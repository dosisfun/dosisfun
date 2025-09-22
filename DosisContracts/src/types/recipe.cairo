use super::drug_type::{DrugType, DrugRarity};

#[derive(Copy, Drop, Serde, Debug, PartialEq, Introspect)]
pub struct Ingredient {
    pub name: felt252,
    pub quantity: u32,
    pub purity: u8, // 0-100
}

#[derive(Copy, Drop, Serde, Debug, PartialEq, Introspect)]
pub struct Recipe {
    pub id: u32,
    pub name: felt252,
    pub drug_type: DrugType,
    pub rarity: DrugRarity,
    pub ingredients: Span<Ingredient>,
    pub difficulty: u8, // 1-10
    pub base_experience: u16,
    pub success_rate: u8, // 0-100
}

#[derive(Copy, Drop, Serde, Debug, PartialEq, Introspect)]
pub enum CraftingResult {
    Success,
    Failure,
    CriticalSuccess,
    CriticalFailure,
}

#[cfg(test)]
mod tests {
    use super::{Ingredient, Recipe, DrugType, DrugRarity, CraftingResult};

    #[test]
    fn test_ingredient_creation() {
        let ingredient = Ingredient {
            name: 'cocaine',
            quantity: 10,
            purity: 85,
        };
        
        assert_eq!(ingredient.name, 'cocaine', "Ingredient name should match");
        assert_eq!(ingredient.quantity, 10, "Quantity should be 10");
        assert_eq!(ingredient.purity, 85, "Purity should be 85");
    }

    #[test]
    fn test_recipe_creation() {
        let mut ingredients = ArrayTrait::new();
        ingredients.append(Ingredient {
            name: 'coca_leaf',
            quantity: 5,
            purity: 90,
        });
        let ingredients_span = ingredients.span();
        
        let recipe = Recipe {
            id: 1,
            name: 'cocaine_basic',
            drug_type: DrugType::Stimulant,
            rarity: DrugRarity::Common,
            ingredients: ingredients_span,
            difficulty: 3,
            base_experience: 50,
            success_rate: 70,
        };
        
        assert_eq!(recipe.id, 1, "Recipe ID should be 1");
        assert_eq!(recipe.difficulty, 3, "Difficulty should be 3");
        assert_eq!(recipe.base_experience, 50, "Base experience should be 50");
    }

    #[test]
    fn test_crafting_result_enum() {
        let success = CraftingResult::Success;
        let failure = CraftingResult::Failure;
        
        assert!(success != failure, "Different crafting results should not be equal");
    }
}
