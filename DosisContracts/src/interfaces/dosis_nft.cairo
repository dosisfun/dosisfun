use crate::models::nft::{CharacterStats, Drug, DrugRarity};

#[starknet::interface]
pub trait IDosisNFT<TContractState> {
    // Character functions
    fn get_character_stats(self: @TContractState, token_id: u256) -> CharacterStats;
    fn update_character_stats(
        ref self: TContractState,
        token_id: u256,
        exp_gain: u16,
        reputation_gain: u16,
        craft_success: bool,
    );
    fn add_cash_and_reputation(
        ref self: TContractState, token_id: u256, cash: u256, reputation: u16,
    );

    // Ingredient functions
    fn get_character_ingredient(self: @TContractState, token_id: u256, ingredient_id: u32) -> u32;
    fn consume_ingredient(
        ref self: TContractState, token_id: u256, ingredient_id: u32, quantity: u32,
    );

    // Drug functions
    fn get_drug(self: @TContractState, drug_id: u32) -> Drug;
    fn create_drug(
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
