use starknet::ContractAddress;
use dosis_game::models::nft::PlayerNFT;

#[starknet::interface]
pub trait IPlayer<T> {
    // NFT Character Management
    fn mint_player_character(ref self: T, character_name: felt252) -> u256;
    fn get_player_character(ref self: T) -> PlayerNFT;
    fn get_player_character_by_id(self: @T, token_id: u256) -> PlayerNFT;
    
    // ERC721 Functions
    fn transfer_player_character(ref self: T, to: ContractAddress, token_id: u256);
    fn safe_transfer_from(ref self: T, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>);
    fn approve_player_character(ref self: T, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: T, operator: ContractAddress, approved: bool);
    fn get_approved(self: @T, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @T, owner: ContractAddress, operator: ContractAddress) -> bool;
    fn balance_of(self: @T, owner: ContractAddress) -> u256;
    fn owner_of(self: @T, token_id: u256) -> ContractAddress;
    fn total_supply(self: @T) -> u256;
    fn supports_interface(self: @T, interface_id: felt252) -> bool;
    
    // Character Stats
    fn get_player_stats(ref self: T) -> (u8, u16, u32, u32, u32, u16);
    fn update_player_stats(ref self: T, level: u8, experience: u16, reputation: u16, total_drugs_created: u32, successful_crafts: u32, failed_crafts: u32);
    fn set_character_active(ref self: T, token_id: u256, is_active: bool);
    
    // Collection Info
    fn name(self: @T) -> felt252;
    fn symbol(self: @T) -> felt252;
    fn token_uri(self: @T, token_id: u256) -> felt252;
    fn token_uri_bytes(self: @T, token_id: u256) -> ByteArray;

    // Admin
    fn set_base_uri(ref self: T, new_base_uri: felt252);
    fn set_paused(ref self: T, is_paused: bool);
}

#[dojo::contract]
pub mod player_system {
    use dosis_game::models::nft::{PlayerNFT, PlayerNFTAssert, ZeroablePlayerNFTTrait, NFTApproval, NFTOperatorApproval, NFTTokenIndex, NFTOwnerTokenIndex, PlayerNFTCollection};
    use dosis_game::store::StoreTrait;
    use dosis_game::constants;
    use starknet::{get_block_timestamp, get_caller_address, ContractAddress};
    use super::IPlayer;

    #[storage]
    struct Storage {
        player_counter: u256,
        owner: ContractAddress,
        paused: bool,
    }

    // Constructor
    fn dojo_init(ref self: ContractState) {
        self.player_counter.write(1);
        self.owner.write(starknet::get_caller_address());
        self.paused.write(false);
        
        // Initialize the NFT collection
        let collection = PlayerNFTCollection {
            collection_id: 1,
            name: 'Dosis Players',
            symbol: 'DOSIS',
            base_uri: 'https://dosis.fun/metadata/',
            total_supply: 0,
            max_supply: 10000,
            is_active: true,
            mint_price: 0,
        };
        
        let mut world = self.world(@"dosis_game");
        let mut store = StoreTrait::new(world);
        store.write_player_nft_collection(collection);
    }

    #[abi(embed_v0)]
    impl PlayerImpl of IPlayer<ContractState> {
        fn mint_player_character(ref self: ContractState, character_name: felt252) -> u256 {
            // Reentrancy/paused guard
            assert(!self.paused.read(), 'Contract is paused');
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let caller = get_caller_address();
            let timestamp = get_block_timestamp();
            
            // Check if caller already owns a player character
            let existing_character = store.get_player_character_by_owner(caller);
            if existing_character.is_non_zero() {
                panic!("Player already owns a character");
            }
            
            // Get current total supply
            let collection = store.read_player_nft_collection();
            let current_supply = collection.total_supply;
            
            // Check max supply
            if current_supply >= collection.max_supply {
                panic!("Maximum supply reached");
            }
            
            // Generate new token ID
            let token_id = current_supply + 1;
            
            // Create new player character NFT
            let player_nft = PlayerNFT {
                token_id,
                owner: caller,
                character_name,
                level: 1,
                experience: 0,
                reputation: 0,
                total_drugs_created: 0,
                successful_crafts: 0,
                failed_crafts: 0,
                creation_timestamp: timestamp,
                last_active_timestamp: timestamp,
                is_minted: true,
                is_active: true,
            };
            
            // Store the NFT
            store.write_player_nft(player_nft);
            
            // Update balance (assume one per owner)
            let mut balance = store.read_nft_balance(caller);
            balance.owner = caller;
            balance.balance = 1;
            store.write_nft_balance(balance);
            
            // Update token index
            let token_index = NFTTokenIndex {
                index: current_supply,
                token_id,
            };
            store.write_nft_token_index(token_index);
            
            // Update owner token index
            let owner_token_index = NFTOwnerTokenIndex {
                owner: caller,
                index: 0,
                token_id,
            };
            store.write_nft_owner_token_index(owner_token_index);
            
            // Update collection total supply
            let mut updated_collection = collection;
            updated_collection.total_supply = current_supply + 1;
            store.write_player_nft_collection(updated_collection);
            
            token_id
        }

        fn get_player_character(ref self: ContractState) -> PlayerNFT {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let caller = get_caller_address();
            
            store.get_player_character_by_owner(caller)
        }

        fn get_player_stats(ref self: ContractState) -> (u8, u16, u32, u32, u32, u16) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let caller = get_caller_address();

            let player_nft = store.get_player_character_by_owner(caller);
            player_nft.assert_exists();

            (
                player_nft.level,
                player_nft.experience,
                player_nft.total_drugs_created,
                player_nft.successful_crafts,
                player_nft.failed_crafts,
                player_nft.reputation
            )
        }

        fn update_player_stats(ref self: ContractState, level: u8, experience: u16, reputation: u16, total_drugs_created: u32, successful_crafts: u32, failed_crafts: u32) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let caller = get_caller_address();
            
            let player_nft = store.get_player_character_by_owner(caller);
            player_nft.assert_exists();
            
            // Create updated NFT
            let mut updated_nft = player_nft;
            updated_nft.level = level;
            updated_nft.experience = experience;
            updated_nft.reputation = reputation;
            updated_nft.total_drugs_created = total_drugs_created;
            updated_nft.successful_crafts = successful_crafts;
            updated_nft.failed_crafts = failed_crafts;
            updated_nft.last_active_timestamp = get_block_timestamp();
            
            // Store updated NFT
            store.write_player_nft(updated_nft);
        }

        fn get_player_character_by_id(self: @ContractState, token_id: u256) -> PlayerNFT {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            
            store.read_player_nft(token_id)
        }

        fn transfer_player_character(ref self: ContractState, to: ContractAddress, token_id: u256) {
            assert(!self.paused.read(), 'Contract is paused');
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let caller = get_caller_address();
            
            // Get the player NFT
            let mut player_nft = store.read_player_nft(token_id);
            player_nft.assert_exists();
            player_nft.assert_owner(caller);
            
            // Update owner
            let from = player_nft.owner;
            player_nft.owner = to;
            player_nft.last_active_timestamp = get_block_timestamp();
            
            // Store updated NFT
            store.write_player_nft(player_nft);
            
            // Update balances
            let from_balance = store.read_nft_balance(from);
            let mut updated_from_balance = from_balance;
            updated_from_balance.balance -= 1;
            store.write_nft_balance(updated_from_balance);
            
            let to_balance = store.read_nft_balance(to);
            let mut updated_to_balance = to_balance;
            updated_to_balance.owner = to;
            updated_to_balance.balance += 1;
            store.write_nft_balance(updated_to_balance);
            
            // Clear approval
            let approval = NFTApproval {
                token_id,
                approved: constants::ZERO_ADDRESS(),
            };
            store.write_nft_approval(approval);
        }

        fn safe_transfer_from(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>) {
            let caller = starknet::get_caller_address();
            assert(from == caller, 'Caller must be from');
            self.transfer_player_character(to, token_id);
        }

        fn approve_player_character(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let caller = get_caller_address();
            
            let player_nft = store.read_player_nft(token_id);
            player_nft.assert_exists();
            player_nft.assert_owner(caller);
            
            let approval = NFTApproval {
                token_id,
                approved: to,
            };
            store.write_nft_approval(approval);
        }

        fn set_approval_for_all(ref self: ContractState, operator: ContractAddress, approved: bool) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let caller = get_caller_address();
            
            let operator_approval = NFTOperatorApproval {
                owner: caller,
                operator,
                approved,
            };
            store.write_nft_operator_approval(operator_approval);
        }

        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            
            let approval = store.read_nft_approval(token_id);
            approval.approved
        }

        fn is_approved_for_all(self: @ContractState, owner: ContractAddress, operator: ContractAddress) -> bool {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            
            let operator_approval = store.read_nft_operator_approval(owner, operator);
            operator_approval.approved
        }

        fn balance_of(self: @ContractState, owner: ContractAddress) -> u256 {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            
            let balance = store.read_nft_balance(owner);
            balance.balance
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            
            let player_nft = store.read_player_nft(token_id);
            player_nft.assert_exists();
            player_nft.owner
        }

        fn total_supply(self: @ContractState) -> u256 {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            
            let collection = store.read_player_nft_collection();
            collection.total_supply
        }

        fn set_character_active(ref self: ContractState, token_id: u256, is_active: bool) {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let caller = get_caller_address();
            
            let mut player_nft = store.read_player_nft(token_id);
            player_nft.assert_exists();
            player_nft.assert_owner(caller);
            
            player_nft.is_active = is_active;
            player_nft.last_active_timestamp = get_block_timestamp();
            
            store.write_player_nft(player_nft);
        }

        fn name(self: @ContractState) -> felt252 {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            
            let collection = store.read_player_nft_collection();
            collection.name
        }

        fn symbol(self: @ContractState) -> felt252 {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            
            let collection = store.read_player_nft_collection();
            collection.symbol
        }

        fn token_uri(self: @ContractState, token_id: u256) -> felt252 {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            
            let collection = store.read_player_nft_collection();
            let base_uri = collection.base_uri;
            base_uri
        }

        fn token_uri_bytes(self: @ContractState, token_id: u256) -> ByteArray {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let collection = store.read_player_nft_collection();
            let base_uri = collection.base_uri;
            let mut out: ByteArray = "";
            out.append_word(base_uri, dosis_game::utils::string::get_short_string_length(base_uri));
            // For now we return only base_uri to keep interface stable
            out
        }

        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            // Recognized interfaces (short string IDs for simplicity)
            let erc165_id = 'ERC165';
            let erc721_id = 'ERC721';
            let erc721_metadata_id = 'ERC721Metadata';
            interface_id == erc165_id || interface_id == erc721_id || interface_id == erc721_metadata_id
        }

        // Admin
        fn set_base_uri(ref self: ContractState, new_base_uri: felt252) {
            assert(self.owner.read() == starknet::get_caller_address(), 'Not owner');
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let mut collection = store.read_player_nft_collection();
            collection.base_uri = new_base_uri;
            store.write_player_nft_collection(collection);
        }

        fn set_paused(ref self: ContractState, is_paused: bool) {
            assert(self.owner.read() == starknet::get_caller_address(), 'Not owner');
            self.paused.write(is_paused);
        }
    }
}
