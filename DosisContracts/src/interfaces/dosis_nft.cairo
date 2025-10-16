use crate::models::nft::{CharacterStats, Drug, DrugRarity};

#[starknet::interface]
pub trait IDosisNFT<TContractState> {
    // Character functions
    fn get_character_stats(self: @TContractState, token_id: u256) -> CharacterStats;
    fn update_character_stats(
        ref self: TContractState,
        token_id: u256,
        cash: u256,
        level: u8,
        experience: u16,
        reputation: u16,
        craft_success: bool,
    );
    // Ingredient functions
    fn get_character_ingredient(self: @TContractState, token_id: u256, ingredient_id: u32) -> u32;
    fn consume_ingredient(
        ref self: TContractState, token_id: u256, ingredient_id: u32, quantity: u32,
    );
    fn mint_ingredient(
        ref self: TContractState, token_id: u256, ingredient_id: u32, quantity: u32, total_cost: u256,
    );

    // Drug functions
    fn get_drug(self: @TContractState, drug_id: u32) -> Drug;
    fn mint_drug(
        ref self: TContractState,
        token_id: u256,
        name: ByteArray,
        rarity: DrugRarity,
        reputation_reward: u32,
        cash_reward: u32,
    ) -> u32;
    fn consume_drug(ref self: TContractState, drug_id: u32);
    fn lock_drug(ref self: TContractState, drug_id: u32);
    fn unlock_drug(ref self: TContractState, drug_id: u32);
    fn transfer_drug_ownership(ref self: TContractState, drug_id: u32, new_owner_token_id: u256);
}
