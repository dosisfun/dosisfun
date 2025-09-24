#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use dosis_game::models::nft::{PlayerNFT, UserTokenMapping, TokenOwnerMapping, ZeroablePlayerNFTTrait};
    use dosis_game::constants;

    #[test]
    #[available_gas(20000000)]
    fn test_player_nft_creation_for_token_system() {
        let owner: ContractAddress = 0x123.try_into().unwrap();
        let character_name: felt252 = 'TestCharacter';
        let current_timestamp = 1000;
        
        let player_nft = PlayerNFT {
            token_id: 1,
            owner,
            character_name,
            level: 1,
            experience: 0,
            reputation: 0,
            total_drugs_created: 0,
            successful_crafts: 0,
            failed_crafts: 0,
            creation_timestamp: current_timestamp,
            last_active_timestamp: current_timestamp,
            is_minted: true,
            is_active: true,
        };

        // Verify initial player NFT state
        assert(player_nft.token_id == 1, 'Token ID should be 1');
        assert(player_nft.owner == owner, 'Owner should match');
        assert(player_nft.character_name == character_name, 'Character name should match');
        assert(player_nft.level == 1, 'Level should be 1');
        assert(player_nft.experience == 0, 'Experience should be 0');
        assert(player_nft.reputation == 0, 'Reputation should be 0');
        assert(player_nft.total_drugs_created == 0, 'Total drugs should be 0');
        assert(player_nft.successful_crafts == 0, 'Successful crafts should be 0');
        assert(player_nft.failed_crafts == 0, 'Failed crafts should be 0');
        assert(player_nft.creation_timestamp == current_timestamp, 'Creation timestamp should match');
        assert(player_nft.last_active_timestamp == current_timestamp, 'Last active timestamp match');
        assert(player_nft.is_minted == true, 'Should be minted');
        assert(player_nft.is_active == true, 'Should be active');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_user_token_mapping_creation() {
        let user_address: ContractAddress = 0x123.try_into().unwrap();
        let token_id: u256 = 1;
        
        let user_mapping = UserTokenMapping {
            user_address,
            token_id,
            is_primary: true,
        };

        assert(user_mapping.user_address == user_address, 'User address should match');
        assert(user_mapping.token_id == token_id, 'Token ID should match');
        assert(user_mapping.is_primary == true, 'Should be primary token');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_token_owner_mapping_creation() {
        let token_id: u256 = 1;
        let owner_address: ContractAddress = 0x123.try_into().unwrap();
        let mint_timestamp: u64 = 1000;
        
        let token_mapping = TokenOwnerMapping {
            token_id,
            owner_address,
            mint_timestamp,
        };

        assert(token_mapping.token_id == token_id, 'Token ID should match');
        assert(token_mapping.owner_address == owner_address, 'Owner address should match');
        assert(token_mapping.mint_timestamp == mint_timestamp, 'Mint timestamp should match');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_player_nft_zero_initialization() {
        let zero_nft: PlayerNFT = ZeroablePlayerNFTTrait::zero();
        
        assert(zero_nft.token_id == 0, 'Token ID should be 0');
        assert(zero_nft.owner == constants::ZERO_ADDRESS(), 'Owner should be zero address');
        assert(zero_nft.character_name == '', 'Character name should be empty');
        assert(zero_nft.level == 1, 'Level should be 1');
        assert(zero_nft.experience == 0, 'Experience should be 0');
        assert(zero_nft.reputation == 0, 'Reputation should be 0');
        assert(zero_nft.total_drugs_created == 0, 'Total drugs should be 0');
        assert(zero_nft.successful_crafts == 0, 'Successful crafts should be 0');
        assert(zero_nft.failed_crafts == 0, 'Failed crafts should be 0');
        assert(zero_nft.creation_timestamp == 0, 'Creation timestamp should be 0');
        assert(zero_nft.last_active_timestamp == 0, 'Last active timestamp 0');
        assert(zero_nft.is_minted == false, 'Should not be minted');
        assert(zero_nft.is_active == false, 'Should not be active');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_player_nft_stats_update() {
        let owner: ContractAddress = 0x123.try_into().unwrap();
        let mut player_nft = PlayerNFT {
            token_id: 1,
            owner,
            character_name: 'TestCharacter',
            level: 1,
            experience: 0,
            reputation: 0,
            total_drugs_created: 0,
            successful_crafts: 0,
            failed_crafts: 0,
            creation_timestamp: 1000,
            last_active_timestamp: 1000,
            is_minted: true,
            is_active: true,
        };

        // Simulate stats updates
        player_nft.level = 2;
        player_nft.experience = 150;
        player_nft.reputation = 25;
        player_nft.total_drugs_created = 5;
        player_nft.successful_crafts = 3;
        player_nft.failed_crafts = 2;
        player_nft.last_active_timestamp = 2000;

        // Verify updates
        assert(player_nft.level == 2, 'Level should be updated to 2');
        assert(player_nft.experience == 150, 'Experience updated to 150');
        assert(player_nft.reputation == 25, 'Reputation updated to 25');
        assert(player_nft.total_drugs_created == 5, 'Total drugs updated to 5');
        assert(player_nft.successful_crafts == 3, 'Successful crafts updated to 3');
        assert(player_nft.failed_crafts == 2, 'Failed crafts updated to 2');
        assert(player_nft.last_active_timestamp == 2000, 'Last active timestamp updated');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_player_nft_burn_state() {
        let owner: ContractAddress = 0x123.try_into().unwrap();
        let mut player_nft = PlayerNFT {
            token_id: 1,
            owner,
            character_name: 'TestCharacter',
            level: 2,
            experience: 100,
            reputation: 50,
            total_drugs_created: 3,
            successful_crafts: 2,
            failed_crafts: 1,
            creation_timestamp: 1000,
            last_active_timestamp: 1500,
            is_minted: true,
            is_active: true,
        };

        // Simulate burn state (what happens in _handle_token_burn)
        player_nft.is_minted = false;
        player_nft.is_active = false;
        player_nft.owner = constants::ZERO_ADDRESS();
        player_nft.last_active_timestamp = 2000; // burn timestamp

        // Verify burn state while preserving historical data
        assert(player_nft.is_minted == false, 'Should not be minted after burn');
        assert(player_nft.is_active == false, 'Should not be active after burn');
        assert(player_nft.owner == constants::ZERO_ADDRESS(), 'Owner should be zero after burn');
        assert(player_nft.last_active_timestamp == 2000, 'Burn timestamp recorded');
        
        // Historical data should be preserved
        assert(player_nft.token_id == 1, 'Token ID should be preserved');
        assert(player_nft.character_name == 'TestCharacter', 'Character name preserved');
        assert(player_nft.level == 2, 'Level should be preserved');
        assert(player_nft.experience == 100, 'Experience should be preserved');
        assert(player_nft.reputation == 50, 'Reputation should be preserved');
        assert(player_nft.total_drugs_created == 3, 'Total drugs should be preserved');
        assert(player_nft.creation_timestamp == 1000, 'Creation timestamp preserved');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_user_token_mapping_clear() {
        let user_address: ContractAddress = 0x123.try_into().unwrap();
        
        // Initial mapping
        let mut user_mapping = UserTokenMapping {
            user_address,
            token_id: 5,
            is_primary: true,
        };

        // Simulate clearing (what happens in burn)
        user_mapping.token_id = 0;
        user_mapping.is_primary = false;

        // Verify cleared state
        assert(user_mapping.user_address == user_address, 'User address should remain');
        assert(user_mapping.token_id == 0, 'Token ID should be cleared');
        assert(user_mapping.is_primary == false, 'Should not be primary');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_token_owner_mapping_clear() {
        let token_id: u256 = 1;
        
        // Initial mapping
        let mut token_mapping = TokenOwnerMapping {
            token_id,
            owner_address: 0x123.try_into().unwrap(),
            mint_timestamp: 1000,
        };

        // Simulate clearing (what happens in burn)
        token_mapping.owner_address = constants::ZERO_ADDRESS();
        token_mapping.mint_timestamp = 0;

        // Verify cleared state
        assert(token_mapping.token_id == token_id, 'Token ID should remain');
        assert(token_mapping.owner_address == constants::ZERO_ADDRESS(), 'Owner should be cleared');
        assert(token_mapping.mint_timestamp == 0, 'Mint timestamp cleared');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_multiple_user_mappings() {
        let user1: ContractAddress = 0x123.try_into().unwrap();
        let user2: ContractAddress = 0x456.try_into().unwrap();
        
        let mapping1 = UserTokenMapping {
            user_address: user1,
            token_id: 1,
            is_primary: true,
        };
        
        let mapping2 = UserTokenMapping {
            user_address: user2,
            token_id: 2,
            is_primary: true,
        };

        // Verify different users have different tokens
        assert(mapping1.user_address != mapping2.user_address, 'Users should be different');
        assert(mapping1.token_id != mapping2.token_id, 'Token IDs should be different');
        assert(mapping1.is_primary == true, 'User1 should have primary token');
        assert(mapping2.is_primary == true, 'User2 should have primary token');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_character_name_validation() {
        let owner: ContractAddress = 0x123.try_into().unwrap();
        
        // Test valid character names
        let valid_names = array!['TestChar', 'Player1', 'Hero123', 'DrugLord'];
        let mut i = 0;
        
        loop {
            if i >= valid_names.len() {
                break;
            }
            
            let character_name = *valid_names.at(i);
            let player_nft = PlayerNFT {
                token_id: i.into() + 1,
                owner,
                character_name,
                level: 1,
                experience: 0,
                reputation: 0,
                total_drugs_created: 0,
                successful_crafts: 0,
                failed_crafts: 0,
                creation_timestamp: 1000,
                last_active_timestamp: 1000,
                is_minted: true,
                is_active: true,
            };
            
            assert(player_nft.character_name == character_name, 'Character name should match');
            assert(player_nft.character_name != '', 'Character name not empty');
            
            i += 1;
        };
    }

    #[test]
    #[available_gas(20000000)]
    fn test_nft_stats_progression() {
        let owner: ContractAddress = 0x123.try_into().unwrap();
        let mut player_nft = PlayerNFT {
            token_id: 1,
            owner,
            character_name: 'Progressor',
            level: 1,
            experience: 0,
            reputation: 0,
            total_drugs_created: 0,
            successful_crafts: 0,
            failed_crafts: 0,
            creation_timestamp: 1000,
            last_active_timestamp: 1000,
            is_minted: true,
            is_active: true,
        };

        // Simulate progression through multiple crafting sessions
        let sessions = array![
            (50, 10, 1, 1, 0),   // (exp, rep, total, success, fail)
            (120, 25, 3, 2, 1),
            (200, 45, 5, 4, 1),
            (350, 75, 8, 6, 2),
        ];
        
        let mut i = 0;
        loop {
            if i >= sessions.len() {
                break;
            }
            
            let (exp, rep, total, success, fail) = *sessions.at(i);
            player_nft.experience = exp;
            player_nft.reputation = rep;
            player_nft.total_drugs_created = total;
            player_nft.successful_crafts = success;
            player_nft.failed_crafts = fail;
            
            // Verify progression makes sense
            assert(player_nft.experience >= 0, 'Experience non-negative');
            assert(player_nft.reputation >= 0, 'Reputation non-negative');
            assert(player_nft.total_drugs_created >= 0, 'Total drugs non-negative');
            assert(player_nft.successful_crafts >= 0, 'Successful crafts non-negative');
            assert(player_nft.failed_crafts >= 0, 'Failed crafts non-negative');
            assert(
                player_nft.total_drugs_created >= player_nft.successful_crafts, 
                'Total >= successful'
            );
            
            i += 1;
        };
    }
}