// Starknet import
use starknet::{ContractAddress, contract_address_const};

// Zero address for initialization
pub fn ZERO_ADDRESS() -> ContractAddress {
    contract_address_const::<0x0>()
}

// Time constants
pub const SECONDS_PER_DAY: u64 = 86400;
pub const SECONDS_PER_HOUR: u64 = 3600;
pub const SECONDS_PER_MINUTE: u64 = 60;

// Player progression constants
pub const BASE_LEVEL_EXPERIENCE: u16 = 100;
pub const LEVEL_EXPERIENCE_MULTIPLIER: u16 = 150;
pub const MAX_PLAYER_LEVEL: u8 = 100;

// Drug crafting constants
pub const BASE_CRAFTING_EXPERIENCE: u16 = 10;
pub const MAX_RECIPE_DIFFICULTY: u8 = 10;
pub const MIN_RECIPE_DIFFICULTY: u8 = 1;
pub const MAX_PURITY: u8 = 100;
pub const MIN_PURITY: u8 = 0;

// Success rate constants
pub const BASE_SUCCESS_RATE: u8 = 50;
pub const MAX_SUCCESS_RATE: u8 = 95;
pub const MIN_SUCCESS_RATE: u8 = 5;

// Reputation constants
pub const BASE_REPUTATION_GAIN: u8 = 1;
pub const LEVEL_UP_REPUTATION_BONUS: u8 = 10;

// Drug rarity multipliers
pub const COMMON_RARITY_MULTIPLIER: u8 = 1;
pub const UNCOMMON_RARITY_MULTIPLIER: u8 = 2;
pub const RARE_RARITY_MULTIPLIER: u8 = 5;
pub const EPIC_RARITY_MULTIPLIER: u8 = 10;
pub const LEGENDARY_RARITY_MULTIPLIER: u8 = 25;