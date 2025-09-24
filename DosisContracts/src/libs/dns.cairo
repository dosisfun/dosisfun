use starknet::ContractAddress;
use dojo::world::{WorldStorage, WorldStorageTrait};

use dosis_game::systems::{
    player_token::{IPlayerTokenDispatcher},
    minter::{IMinterDispatcher},
};

pub mod SELECTORS {
    // systems
    pub const PLAYER_TOKEN: felt252 = selector_from_tag!("dosis_game-player_token");
    pub const MINTER: felt252 = selector_from_tag!("dosis_game-minter");
}

#[generate_trait]
pub impl DnsImpl of DnsTrait {
    fn find_contract_address(self: @WorldStorage, contract_name: @ByteArray) -> ContractAddress {
        match self.dns_address(contract_name) {
            Option::Some(contract_address) => contract_address,
            Option::None => 0.try_into().unwrap(), // ZERO address
        }
    }

    //--------------------------
    // system addresses
    //
    #[inline(always)]
    fn player_token_address(self: @WorldStorage) -> ContractAddress {
        self.find_contract_address(@"player_token")
    }
    
    #[inline(always)]
    fn minter_address(self: @WorldStorage) -> ContractAddress {
        self.find_contract_address(@"minter")
    }

    //--------------------------
    // dispatchers
    //
    #[inline(always)]
    fn player_token_dispatcher(self: @WorldStorage) -> IPlayerTokenDispatcher {
        IPlayerTokenDispatcher { contract_address: self.player_token_address() }
    }
    
    #[inline(always)]
    fn minter_dispatcher(self: @WorldStorage) -> IMinterDispatcher {
        IMinterDispatcher { contract_address: self.minter_address() }
    }
}
