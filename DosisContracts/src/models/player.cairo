// Constants imports
use dosis_game::constants;
use core::num::traits::zero::Zero;
use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct Player {
    #[key]
    pub address: ContractAddress,
    pub level: u8,
    pub experience: u16,
    pub total_drugs_created: u32,
    pub successful_crafts: u32,
    pub failed_crafts: u32,
    pub last_active_timestamp: u64,
    pub creation_timestamp: u64,
    pub reputation: u16, // 0-1000
}

#[generate_trait]
pub impl PlayerAssert of AssertTrait {
    #[inline(always)]
    fn assert_exists(self: Player) {
        assert(self.is_non_zero(), 'Player: Does not exist');
    }

    #[inline(always)]
    fn assert_not_exists(self: Player) {
        assert(self.is_zero(), 'Player: Already exist');
    }
}

pub impl ZeroablePlayerTrait of Zero<Player> {
    #[inline(always)]
    fn zero() -> Player {
        Player {
            address: constants::ZERO_ADDRESS(),
            level: 1,
            experience: 0,
            total_drugs_created: 0,
            successful_crafts: 0,
            failed_crafts: 0,
            last_active_timestamp: 0,
            creation_timestamp: 0,
            reputation: 0,
        }
    }

    #[inline(always)]
    fn is_zero(self: @Player) -> bool {
        *self.address == constants::ZERO_ADDRESS()
    }

    #[inline(always)]
    fn is_non_zero(self: @Player) -> bool {
        !self.is_zero()
    }
}

#[cfg(test)]
mod tests {
    use dosis_game::constants;
    use starknet::{ContractAddress, contract_address_const};
    use super::{Player, ZeroablePlayerTrait};

    #[test]
    #[available_gas(1000000)]
    fn test_player_initialization() {
        let mock_address: ContractAddress = contract_address_const::<0x123>();

        let player = Player {
            address: mock_address,
            level: 1,
            experience: 0,
            total_drugs_created: 0,
            successful_crafts: 0,
            failed_crafts: 0,
            last_active_timestamp: 0,
            creation_timestamp: 1234567890,
            reputation: 0,
        };

        assert_eq!(player.address, mock_address, "Player address should match");
        assert_eq!(player.level, 1, "Level should be 1");
        assert_eq!(player.experience, 0, "Experience should be 0");
        assert_eq!(player.total_drugs_created, 0, "Total drugs created should be 0");
        assert_eq!(player.reputation, 0, "Reputation should be 0");
    }

    #[test]
    #[available_gas(1000000)]
    fn test_player_initialization_zero_values() {
        let player: Player = ZeroablePlayerTrait::zero();

        assert_eq!(
            player.address,
            constants::ZERO_ADDRESS(),
            "Player address should be zero address",
        );
        assert_eq!(player.level, 1, "Level should be 1");
        assert_eq!(player.experience, 0, "Experience should be 0");
    }

    #[test]
    #[available_gas(1000000)]
    fn test_player_with_experience() {
        let mock_address: ContractAddress = contract_address_const::<0x456>();

        let player = Player {
            address: mock_address,
            level: 5,
            experience: 250,
            total_drugs_created: 10,
            successful_crafts: 8,
            failed_crafts: 2,
            last_active_timestamp: 1234567890,
            creation_timestamp: 1234560000,
            reputation: 150,
        };

        assert_eq!(player.level, 5, "Level should be 5");
        assert_eq!(player.experience, 250, "Experience should be 250");
        assert_eq!(player.total_drugs_created, 10, "Total drugs created should be 10");
        assert_eq!(player.successful_crafts, 8, "Successful crafts should be 8");
        assert_eq!(player.failed_crafts, 2, "Failed crafts should be 2");
        assert_eq!(player.reputation, 150, "Reputation should be 150");
    }

    #[test]
    #[available_gas(1000000)]
    fn test_player_address_uniqueness() {
        let address1: ContractAddress = contract_address_const::<0x123>();
        let address2: ContractAddress = contract_address_const::<0x456>();

        let player1 = Player {
            address: address1,
            level: 1,
            experience: 0,
            total_drugs_created: 0,
            successful_crafts: 0,
            failed_crafts: 0,
            last_active_timestamp: 0,
            creation_timestamp: 0,
            reputation: 0,
        };

        let player2 = Player {
            address: address2,
            level: 1,
            experience: 0,
            total_drugs_created: 0,
            successful_crafts: 0,
            failed_crafts: 0,
            last_active_timestamp: 0,
            creation_timestamp: 0,
            reputation: 0,
        };

        assert!(player1.address != player2.address, "Players should have unique addresses");
    }
}

