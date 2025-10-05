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
    pub created_by: felt252 // Creator address as felt252
}


#[derive(Copy, Drop, Serde, Debug, PartialEq, Introspect)]
pub struct Ingredient {
    pub name: felt252,
    pub quantity: u32,
    pub purity: u8 // 0-100
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
    pub success_rate: u8 // 0-100
}
