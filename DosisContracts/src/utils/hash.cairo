use starknet::ContractAddress;
use core::poseidon::PoseidonTrait;
use core::hash::HashStateTrait;

/// Generate a deterministic seed for a token based on contract address and token ID
pub fn make_seed(contract_address: ContractAddress, token_id: u256) -> felt252 {
    let mut hasher = PoseidonTrait::new();
    hasher = hasher.update(contract_address.into());
    hasher = hasher.update(token_id.low.into());
    hasher = hasher.update(token_id.high.into());
    hasher = hasher.update(starknet::get_block_timestamp().into());
    hasher.finalize()
}

/// Generate a deterministic seed for a token based on contract address and u128 token ID (legacy)
pub fn make_seed_u128(contract_address: ContractAddress, token_id: u128) -> felt252 {
    make_seed(contract_address, token_id.into())
}

/// Hash multiple values together
pub fn hash_values(values: Span<felt252>) -> felt252 {
    let mut hasher = PoseidonTrait::new();
    let mut i = 0;
    loop {
        if i >= values.len() {
            break;
        }
        hasher = hasher.update(*values.at(i));
        i += 1;
    };
    hasher.finalize()
}

/// Generate a random-like value from a seed
pub fn pseudo_random_from_seed(seed: felt252, nonce: u256) -> felt252 {
    let mut hasher = PoseidonTrait::new();
    hasher = hasher.update(seed);
    hasher = hasher.update(nonce.low.into());
    hasher = hasher.update(nonce.high.into());
    hasher.finalize()
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_make_seed() {
        let contract_addr: ContractAddress = 0x123.try_into().unwrap();
        let token_id: u256 = 1;
        
        let seed1 = make_seed(contract_addr, token_id);
        let seed2 = make_seed(contract_addr, token_id);
        
        // Seeds should be deterministic (same inputs = same output)
        assert(seed1 == seed2, 'Seeds should be deterministic');
        
        // Different token IDs should produce different seeds
        let seed3 = make_seed(contract_addr, 2);
        assert(seed1 != seed3, 'Different tokens != seeds');
        
        // Different contracts should produce different seeds
        let contract_addr2: ContractAddress = 0x456.try_into().unwrap();
        let seed4 = make_seed(contract_addr2, token_id);
        assert(seed1 != seed4, 'Different contracts != seeds');
    }
    
    #[test]
    fn test_make_seed_u128() {
        let contract_addr: ContractAddress = 0x123.try_into().unwrap();
        let token_id_u128: u128 = 1;
        let token_id_u256: u256 = 1;
        
        let seed_u128 = make_seed_u128(contract_addr, token_id_u128);
        let seed_u256 = make_seed(contract_addr, token_id_u256);
        
        // Should produce the same result
        assert(seed_u128 == seed_u256, 'u128 and u256 should match');
    }
    
    #[test]
    fn test_hash_values() {
        let values = array![0x1, 0x2, 0x3].span();
        let hash1 = hash_values(values);
        let hash2 = hash_values(values);
        
        // Should be deterministic
        assert(hash1 == hash2, 'Hash should be deterministic');
        
        // Different values should produce different hashes
        let values2 = array![0x1, 0x2, 0x4].span();
        let hash3 = hash_values(values2);
        assert(hash1 != hash3, 'Different values != hashes');
    }
    
    #[test]
    fn test_pseudo_random_from_seed() {
        let seed: felt252 = 0x12345;
        let nonce1: u256 = 1;
        let nonce2: u256 = 2;
        
        let random1 = pseudo_random_from_seed(seed, nonce1);
        let random2 = pseudo_random_from_seed(seed, nonce2);
        
        // Different nonces should produce different results
        assert(random1 != random2, 'Different nonces != results');
        
        // Same inputs should produce same results
        let random3 = pseudo_random_from_seed(seed, nonce1);
        assert(random1 == random3, 'Same inputs = same results');
    }
}
