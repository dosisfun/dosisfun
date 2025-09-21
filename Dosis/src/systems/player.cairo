#[starknet::interface]
pub trait IPlayer<T> {
    fn spawn_player(ref self: T);
    fn get_player_stats(ref self: T) -> (u8, u16, u32, u32, u32, u16);
}

#[dojo::contract]
pub mod player_system {
    use dosis_game::models::player::{Player, PlayerAssert};
    use dosis_game::store::StoreTrait;
    use starknet::{get_block_timestamp, get_caller_address};
    use super::IPlayer;

    #[storage]
    struct Storage {
        player_counter: u256,
    }

    // Constructor
    fn dojo_init(ref self: ContractState) {
        self.player_counter.write(1);
    }

    #[abi(embed_v0)]
    impl PlayerImpl of IPlayer<ContractState> {
        fn spawn_player(ref self: ContractState) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let found = store.read_player();
            found.assert_not_exists();

            let player = Player {
                address: get_caller_address(),
                level: 1,
                experience: 0,
                total_drugs_created: 0,
                successful_crafts: 0,
                failed_crafts: 0,
                last_active_timestamp: get_block_timestamp(),
                creation_timestamp: get_block_timestamp(),
                reputation: 0,
            };

            store.write_player(player);
        }

        fn get_player_stats(ref self: ContractState) -> (u8, u16, u32, u32, u32, u16) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);

            let player = store.read_player();
            player.assert_exists();

            (
                player.level,
                player.experience,
                player.total_drugs_created,
                player.successful_crafts,
                player.failed_crafts,
                player.reputation
            )
        }
    }
}
