use core::num::traits::zero::Zero;
use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct Drug {
    #[key]
    pub id: u32,
    pub name: ByteArray,
    pub rarity: DrugRarity,
    pub reputation_reward: u32,
    pub cash_reward: u32,
    pub owner: ContractAddress, // TODO: 
}

// Deberia estar en el NFT
#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct DrugInventory {
    #[key]
    pub player: ContractAddress,
    pub drug_ids: Span<u32>,
    pub total_drugs: u32,
}

#[derive(Copy, Drop, Serde, Debug, PartialEq, Introspect)]
pub enum DrugRarity {
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
}

#[derive(Copy, Drop, Serde, Debug, PartialEq, Introspect)]
pub struct Ingredient {
    #[key]
    pub id: u32,
    pub name: felt252,
    pub price_in_cash: u32,
    pub quantity: u32,
}
