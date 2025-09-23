use starknet::ContractAddress;
use core::num::traits::zero::Zero;

/// Player Character NFT - represents a player character in the game
#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct PlayerNFT {
    #[key]
    pub token_id: u256,
    pub owner: ContractAddress,
    pub character_name: felt252,
    pub level: u8,
    pub experience: u16,
    pub reputation: u16, // 0-1000
    pub total_drugs_created: u32,
    pub successful_crafts: u32,
    pub failed_crafts: u32,
    pub creation_timestamp: u64,
    pub last_active_timestamp: u64,
    pub is_minted: bool,
    pub is_active: bool, // whether the character is currently active
}

/// User to Token ID mapping - tracks which token belongs to each user
#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct UserTokenMapping {
    #[key]
    pub user_address: ContractAddress,
    pub token_id: u256,
    pub is_primary: bool, // allows for multiple tokens per user in future
}

/// Token to User mapping - reverse lookup
#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct TokenOwnerMapping {
    #[key]
    pub token_id: u256,
    pub owner_address: ContractAddress,
    pub mint_timestamp: u64,
}

/// NFT Balance tracking for ERC721 compliance
#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct NFTBalance {
    #[key]
    pub owner: ContractAddress,
    pub balance: u256,
}

/// NFT Approval tracking for ERC721 compliance
#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct NFTApproval {
    #[key]
    pub token_id: u256,
    pub approved: ContractAddress,
}

/// NFT Operator Approval tracking for ERC721 compliance
#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct NFTOperatorApproval {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub operator: ContractAddress,
    pub approved: bool,
}

/// NFT Token Index tracking for enumeration
#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct NFTTokenIndex {
    #[key]
    pub index: u256,
    pub token_id: u256,
}

/// NFT Owner Token Index tracking for enumeration
#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct NFTOwnerTokenIndex {
    #[key]
    pub owner: ContractAddress,
    #[key]
    pub index: u256,
    pub token_id: u256,
}

/// Player NFT Collection metadata
#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct PlayerNFTCollection {
    #[key]
    pub collection_id: u256,
    pub name: felt252, // "Dosis Players"
    pub symbol: felt252, // "DOSIS"
    pub base_uri: felt252,
    pub total_supply: u256,
    pub max_supply: u256,
    pub is_active: bool,
    pub mint_price: u256, // price to mint a new player character
}

#[generate_trait]
pub impl PlayerNFTAssert of AssertTrait {
    #[inline(always)]
    fn assert_exists(self: PlayerNFT) {
        assert(self.is_minted, 'PlayerNFT: Token does not exist');
    }

    #[inline(always)]
    fn assert_not_exists(self: PlayerNFT) {
        assert(!self.is_minted, 'PlayerNFT: Token already exists');
    }

    #[inline(always)]
    fn assert_owner(self: PlayerNFT, owner: ContractAddress) {
        assert(self.owner == owner, 'PlayerNFT: Not the owner');
    }

    #[inline(always)]
    fn assert_not_owner(self: PlayerNFT, owner: ContractAddress) {
        assert(self.owner != owner, 'PlayerNFT: Is the owner');
    }

    #[inline(always)]
    fn assert_active(self: PlayerNFT) {
        assert(self.is_active, 'PlayerNFT: Character not active');
    }
}

pub impl ZeroablePlayerNFTTrait of Zero<PlayerNFT> {
    #[inline(always)]
    fn zero() -> PlayerNFT {
        PlayerNFT {
            token_id: 0,
            owner: 0.try_into().unwrap(),
            character_name: '',
            level: 1,
            experience: 0,
            reputation: 0,
            total_drugs_created: 0,
            successful_crafts: 0,
            failed_crafts: 0,
            creation_timestamp: 0,
            last_active_timestamp: 0,
            is_minted: false,
            is_active: false,
        }
    }

    #[inline(always)]
    fn is_zero(self: @PlayerNFT) -> bool {
        *self.token_id == 0
    }

    #[inline(always)]
    fn is_non_zero(self: @PlayerNFT) -> bool {
        !self.is_zero()
    }
}

#[cfg(test)]
mod tests {
    use super::{PlayerNFT, NFTBalance, NFTApproval, NFTOperatorApproval, ZeroablePlayerNFTTrait};
    use starknet::ContractAddress;

    #[test]
    fn test_player_nft_creation() {
        let owner: ContractAddress = 0x123.try_into().unwrap();
        
        let player_nft = PlayerNFT {
            token_id: 1,
            owner,
            character_name: 'Shadow Dealer',
            level: 5,
            experience: 250,
            reputation: 150,
            total_drugs_created: 10,
            successful_crafts: 8,
            failed_crafts: 2,
            creation_timestamp: 1234567890,
            last_active_timestamp: 1234567890,
            is_minted: true,
            is_active: true,
        };

        assert_eq!(player_nft.token_id, 1, "Token ID should be 1");
        assert_eq!(player_nft.owner, owner, "Owner should match");
        assert_eq!(player_nft.level, 5, "Level should be 5");
        assert_eq!(player_nft.experience, 250, "Experience should be 250");
        assert_eq!(player_nft.reputation, 150, "Reputation should be 150");
        assert_eq!(player_nft.is_minted, true, "Should be minted");
        assert_eq!(player_nft.is_active, true, "Should be active");
    }

    #[test]
    fn test_player_nft_zero_initialization() {
        let zero_player_nft: PlayerNFT = ZeroablePlayerNFTTrait::zero();
        
        assert_eq!(zero_player_nft.token_id, 0, "Zero PlayerNFT token ID should be 0");
        assert_eq!(zero_player_nft.level, 1, "Zero PlayerNFT level should be 1");
        assert_eq!(zero_player_nft.experience, 0, "Zero PlayerNFT experience should be 0");
        assert_eq!(zero_player_nft.reputation, 0, "Zero PlayerNFT reputation should be 0");
        assert_eq!(zero_player_nft.is_minted, false, "Should not be minted");
        assert_eq!(zero_player_nft.is_active, false, "Should not be active");
    }

    #[test]
    fn test_nft_balance_creation() {
        let owner: ContractAddress = 0x456.try_into().unwrap();
        
        let balance = NFTBalance {
            owner,
            balance: 5,
        };

        assert_eq!(balance.owner, owner, "Owner should match");
        assert_eq!(balance.balance, 5, "Balance should be 5");
    }

    #[test]
    fn test_nft_approval_creation() {
        let token_id: u256 = 1;
        let approved: ContractAddress = 0x789.try_into().unwrap();
        
        let approval = NFTApproval {
            token_id,
            approved,
        };

        assert_eq!(approval.token_id, token_id, "Token ID should match");
        assert_eq!(approval.approved, approved, "Approved address should match");
    }

    #[test]
    fn test_nft_operator_approval_creation() {
        let owner: ContractAddress = 0x123.try_into().unwrap();
        let operator: ContractAddress = 0x456.try_into().unwrap();
        
        let operator_approval = NFTOperatorApproval {
            owner,
            operator,
            approved: true,
        };

        assert_eq!(operator_approval.owner, owner, "Owner should match");
        assert_eq!(operator_approval.operator, operator, "Operator should match");
        assert_eq!(operator_approval.approved, true, "Approved should be true");
    }
}
