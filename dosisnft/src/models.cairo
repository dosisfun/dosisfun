use starknet::ContractAddress;

#[derive(Drop, Serde, starknet::Store)]
pub struct CharacterStats {
    pub owner: ContractAddress,
    pub character_name: ByteArray,
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
