use starknet::ContractAddress;

#[derive(Drop, Serde, starknet::Store)]
pub struct CharacterStats {
    pub owner: ContractAddress,
    pub character_name: ByteArray,
    pub cash: u256,
    pub level: u8,
    pub experience: u16,
    pub reputation: u16, // 0-1000
    pub total_drugs_created: u32,
    pub successful_crafts: u32,
    pub failed_crafts: u32,
    pub creation_timestamp: u64,
    pub last_active_timestamp: u64,
    pub is_minted: bool,
    pub is_active: bool // whether the character is currently active
}

#[derive(Drop, Serde, starknet::Store)]
pub struct Drug {
    pub id: u32,
    pub owner_token_id: u256,
    pub name: ByteArray,
    pub rarity: DrugRarity,
    pub reputation_reward: u32,
    pub cash_reward: u32,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub enum DrugRarity {
    #[default]
    Base,
    Common,
    Rare,
    UltraRare,
    Legendary,
}
