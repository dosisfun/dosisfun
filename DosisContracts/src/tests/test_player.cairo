use dosis_game::models::player::{PlayerAssert, ZeroablePlayerTrait};

#[cfg(test)]
mod tests {
    use super::{PlayerAssert, ZeroablePlayerTrait};
    use dosis_game::constants;

    #[test]
    #[available_gas(20000000)]
    fn test_player_creation() {
        let mut player = ZeroablePlayerTrait::zero();
        player.level = 1;
        player.experience = 0;
        player.total_drugs_created = 0;
        player.successful_crafts = 0;
        player.failed_crafts = 0;
        player.last_active_timestamp = 1000;
        player.creation_timestamp = 1000;
        player.reputation = 0;

        assert(player.level == 1, 'Player level should be 1');
        assert(player.experience == 0, 'Player experience should be 0');
        assert(player.total_drugs_created == 0, 'Total drugs created should be 0');
        assert(player.successful_crafts == 0, 'Successful crafts should be 0');
        assert(player.failed_crafts == 0, 'Failed crafts should be 0');
        assert(player.reputation == 0, 'Reputation should be 0');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_player_zero_address() {
        let player = ZeroablePlayerTrait::zero();
        assert(player.address == constants::ZERO_ADDRESS(), 'Address should be zero address');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_player_assert_exists() {
        let mut player = ZeroablePlayerTrait::zero();
        player.address = 0x123.try_into().unwrap(); // Set a valid address
        
        // This should not panic
        player.assert_exists();
    }

    #[test]
    #[available_gas(20000000)]
    fn test_player_stats_update() {
        let mut player = ZeroablePlayerTrait::zero();
        player.level = 5;
        player.experience = 250;
        player.total_drugs_created = 10;
        player.successful_crafts = 8;
        player.failed_crafts = 2;
        player.reputation = 15;

        assert(player.level == 5, 'Level should be 5');
        assert(player.experience == 250, 'Experience should be 250');
        assert(player.total_drugs_created == 10, 'Total drugs should be 10');
        assert(player.successful_crafts == 8, 'Successful crafts should be 8');
        assert(player.failed_crafts == 2, 'Failed crafts should be 2');
        assert(player.reputation == 15, 'Reputation should be 15');
    }
}
