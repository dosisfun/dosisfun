use starknet::ContractAddress;

pub fn NAMESPACE() -> @ByteArray{
    @"dosis_game2"
}

pub fn NFT_CONTRACTS() -> ContractAddress {
    0x02232fb520090d5c76d8d84de9829eea7c34c5e6234a5a2a8b178d18e2aedbd7.try_into().unwrap()
}

// Ingredient IDs
pub const INGREDIENT_RUCUCU_OG: u32 = 1;
pub const INGREDIENT_OG_KUSH: u32 = 2;
pub const INGREDIENT_PINEAPPLE_EXPRESS: u32 = 3;
pub const INGREDIENT_GELATO: u32 = 4;
pub const INGREDIENT_BLUE_DREAM: u32 = 5;
