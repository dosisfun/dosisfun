use starknet::{ContractAddress};

#[starknet::interface]
pub trait IPlayerToken<TState> {
    // Dosis Hybrid Functions (ERC721 + Game Logic)
    fn mint_player_character(ref self: TState, recipient: ContractAddress, character_name: felt252) -> u256;
    fn get_player_token_id(self: @TState, owner: ContractAddress) -> u256;
    fn get_player_game_stats(self: @TState, token_id: u256) -> (u8, u16, u16, u32, u32, u32);
    fn update_player_game_stats(ref self: TState, token_id: u256, level: u8, experience: u16, reputation: u16);
    fn set_character_active(ref self: TState, token_id: u256, is_active: bool);
    
    // Token Management
    fn burn_token(ref self: TState, token_id: u256);
    
    // Admin
    fn set_paused(ref self: TState, is_paused: bool);
    fn update_token_metadata(ref self: TState, token_id: u256);
    fn set_contract_admin(ref self: TState, new_admin: ContractAddress);
    fn get_contract_admin(self: @TState) -> ContractAddress;
}

#[dojo::contract]
pub mod player_token {
    use starknet::{ContractAddress, storage::{StoragePointerReadAccess, StoragePointerWriteAccess}};
    use dojo::world::{WorldStorage};

    //-----------------------------------
    // ERC721 Integration (dosis_nft)
    //
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::ERC721Component;
    use dosis_nft::erc721::erc721_dosis::ERC721DosisComponent;
    use dosis_nft::erc721::erc721_dosis::ERC721DosisComponent::{ERC721HooksImpl};
    use dosis_nft::utils::{renderer};
    use renderer::{ContractMetadata, TokenMetadata};
    
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ERC721DosisComponent, storage: erc721_dosis, event: ERC721DosisEvent);
    
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl ERC721DosisInternalImpl = ERC721DosisComponent::InternalImpl<ContractState>;
    
    #[abi(embed_v0)]
    impl ERC721DosisMixinImpl = ERC721DosisComponent::ERC721DosisMixinImpl<ContractState>;
    
    #[storage]
    struct Storage {
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        erc721_dosis: ERC721DosisComponent::Storage,
        // Contract admin
        contract_admin: ContractAddress,
    }
    
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        ERC721DosisEvent: ERC721DosisComponent::Event,
    }
    //
    // ERC721 end
    //-----------------------------------

    // Dojo Game Data Integration
    use dosis_game::models::nft::{PlayerNFT, PlayerNFTAssert, ZeroablePlayerNFTTrait};
    use dosis_game::store::{Store, StoreTrait};
    use dosis_game::libs::dns::{DnsTrait};
    use dosis_game::constants;

    mod Errors {
        pub const CALLER_IS_NOT_OWNER: felt252 = 'DOSIS: caller is not owner';
        pub const CALLER_IS_NOT_MINTER: felt252 = 'DOSIS: caller is not minter';
        pub const TOKEN_NOT_EXISTS: felt252 = 'DOSIS: token does not exist';
        pub const INVALID_CHARACTER_NAME: felt252 = 'DOSIS: invalid character name';
        pub const PLAYER_ALREADY_HAS_TOKEN: felt252 = 'DOSIS: player has token';
        pub const NOT_ADMIN_OR_OWNER: felt252 = 'DOSIS: not admin or owner';
    }

    fn dojo_init(ref self: ContractState) {
        // Initialize ERC721 from dosis_nft
        self.erc721_dosis.initializer(
            "Dosis Player Characters",
            "DOSIS",
            Option::None, // use hooks for base_uri
            Option::None, // use hooks for contract_uri
            Option::Some(constants::MAX_PLAYER_NFT_SUPPLY), // max_supply
        );
        
        // Set the deployer as initial admin
        self.contract_admin.write(starknet::get_caller_address());
    }

    #[generate_trait]
    impl WorldDefaultImpl of WorldDefaultTrait {
        #[inline(always)]
        fn world_default(self: @ContractState) -> WorldStorage {
            (self.world(@"dosis_game"))
        }
    }

    //-----------------------------------
    // Hybrid Implementation
    //
    #[abi(embed_v0)]
    impl IPlayerTokenImpl of super::IPlayerToken<ContractState> {

        fn mint_player_character(ref self: ContractState, recipient: ContractAddress, character_name: felt252) -> u256 {
            // Validate character name
            assert(character_name != '', Errors::INVALID_CHARACTER_NAME);
            assert(!recipient.is_zero(), Errors::INVALID_CHARACTER_NAME);
            
            // Verify caller is the minter (not hardcoded!)
            let store = StoreTrait::new(self.world_default());
            self._assert_caller_is_minter(@store);
            
            // Check if player already has a token (one per address policy)
            assert(self.erc721_dosis.balance_of(recipient) == 0, Errors::PLAYER_ALREADY_HAS_TOKEN);

            // 1. Mint ERC721 token using dosis_nft
            let token_id: u256 = self.erc721_dosis._mint_next(recipient);

            // 2. Create corresponding Dojo game data
            let mut store = StoreTrait::new(self.world_default());
            let player_nft = PlayerNFT {
                token_id: token_id.low.try_into().unwrap(),
                owner: recipient,
                character_name,
                level: 1,
                experience: 0,
                reputation: 0,
                total_drugs_created: 0,
                successful_crafts: 0,
                failed_crafts: 0,
                creation_timestamp: starknet::get_block_timestamp(),
                last_active_timestamp: starknet::get_block_timestamp(),
                is_minted: true,
                is_active: true,
            };
            store.write_player_nft(player_nft);
            
            // Set up proper user->token mapping
            store.set_user_primary_token(recipient, token_id);

            token_id
        }

        fn get_player_token_id(self: @ContractState, owner: ContractAddress) -> u256 {
            // Use proper mapping to get user's primary token
            let store = StoreTrait::new(self.world_default());
            store.get_user_primary_token_id(owner)
        }

        fn get_player_game_stats(self: @ContractState, token_id: u256) -> (u8, u16, u16, u32, u32, u32) {
            // Verify token exists
            assert(self.erc721_dosis.token_exists(token_id), Errors::TOKEN_NOT_EXISTS);
            
            // Get game data from Dojo
            let store = StoreTrait::new(self.world_default());
            let player_nft = store.read_player_nft(token_id.low.try_into().unwrap());
            
            (
                player_nft.level,
                player_nft.experience,
                player_nft.reputation,
                player_nft.total_drugs_created,
                player_nft.successful_crafts,
                player_nft.failed_crafts
            )
        }

        fn update_player_game_stats(ref self: ContractState, token_id: u256, level: u8, experience: u16, reputation: u16) {
            // Verify caller owns the token
            let caller = starknet::get_caller_address();
            let owner = self.erc721_dosis.owner_of(token_id);
            assert(owner == caller, Errors::CALLER_IS_NOT_OWNER);

            // Update game data in Dojo
            let mut store = StoreTrait::new(self.world_default());
            let mut player_nft = store.read_player_nft(token_id.low.try_into().unwrap());
            
            player_nft.level = level;
            player_nft.experience = experience;
            player_nft.reputation = reputation;
            player_nft.last_active_timestamp = starknet::get_block_timestamp();
            
            store.write_player_nft(player_nft);

            // Emit metadata update for NFT marketplaces
            self.erc721_dosis._emit_metadata_update(token_id);
        }

        fn set_character_active(ref self: ContractState, token_id: u256, is_active: bool) {
            // Verify caller owns the token
            let caller = starknet::get_caller_address();
            let owner = self.erc721_dosis.owner_of(token_id);
            assert(owner == caller, Errors::CALLER_IS_NOT_OWNER);

            // Update active status in Dojo
            let mut store = StoreTrait::new(self.world_default());
            let mut player_nft = store.read_player_nft(token_id.low.try_into().unwrap());
            
            player_nft.is_active = is_active;
            player_nft.last_active_timestamp = starknet::get_block_timestamp();
            
            store.write_player_nft(player_nft);
        }

        fn burn_token(ref self: ContractState, token_id: u256) {
            // Only token owner or contract admin can burn
            let caller = starknet::get_caller_address();
            let owner = self.erc721_dosis.owner_of(token_id);
            let is_admin = self._is_contract_admin(caller);
            
            assert(
                owner == caller || is_admin,
                Errors::NOT_ADMIN_OR_OWNER
            );

            // Burn the ERC721 token (this will trigger after_update hook)
            self.erc721.burn(token_id);
        }

        // Admin functions  
        fn set_paused(ref self: ContractState, is_paused: bool) {
            // Only contract admin can pause/unpause
            let caller = starknet::get_caller_address();
            assert(self._is_contract_admin(caller), Errors::NOT_ADMIN_OR_OWNER);
            
            self.erc721_dosis._set_minting_paused(is_paused);
        }

        fn update_token_metadata(ref self: ContractState, token_id: u256) {
            // Only contract admin can trigger metadata updates
            let caller = starknet::get_caller_address();
            assert(self._is_contract_admin(caller), Errors::NOT_ADMIN_OR_OWNER);
            
            self.erc721_dosis._emit_metadata_update(token_id);
        }

        fn set_contract_admin(ref self: ContractState, new_admin: ContractAddress) {
            self._set_contract_admin(new_admin);
        }

        fn get_contract_admin(self: @ContractState) -> ContractAddress {
            self.contract_admin.read()
        }
    }

    //-----------------------------------
    // ERC721DosisHooksTrait Implementation
    //
    pub impl ERC721DosisHooksImpl of ERC721DosisComponent::ERC721DosisHooksTrait<ContractState> {
        fn before_update(
            ref self: ERC721DosisComponent::ComponentState<ContractState>,
            to: ContractAddress,
            token_id: u256,
            auth: ContractAddress,
        ) {
            // Custom logic before token updates (mints/transfers/burns)
        }

        fn after_update(
            ref self: ERC721DosisComponent::ComponentState<ContractState>,
            to: ContractAddress,
            token_id: u256,
            auth: ContractAddress,
        ) {
            let self = self.get_contract();
            let mut store = StoreTrait::new(self.world_default());
            
            if to.is_zero() {
                // Token is being burned - clean up all data
                self._handle_token_burn(store, token_id);
            } else {
                // Token was transferred to a new owner, update our mappings
                store.update_token_ownership(token_id, to);
            }
        }
        fn render_contract_uri(self: @ERC721DosisComponent::ComponentState<ContractState>) -> Option<ContractMetadata> {
            let metadata = ContractMetadata {
                name: self.name(),
                symbol: self.symbol(),
                description: "Dosis Player Character NFTs - Your identity in the Dosis drug crafting game",
                image: Option::Some("https://dosis.fun/images/contract-image.png"),
                banner_image: Option::Some("https://dosis.fun/images/banner.png"),
                featured_image: Option::None,
                external_link: Option::Some("https://dosis.fun"),
                collaborators: Option::None,
            };
            (Option::Some(metadata))
        }

        fn render_token_uri(self: @ERC721DosisComponent::ComponentState<ContractState>, token_id: u256) -> Option<TokenMetadata> {
            let self = self.get_contract(); // get the component's contract state
            let store = StoreTrait::new(self.world_default());
            
            // Get player game data from Dojo
            let player_nft = store.read_player_nft(token_id.low.try_into().unwrap());
            
            // Generate metadata combining ERC721 + game data
            let character_name_str = if player_nft.character_name != '' {
                format!("{}", player_nft.character_name)
            } else {
                format!("Player #{}", token_id.low)
            };

            // Create enhanced description with dynamic stats
            let _success_rate = if player_nft.total_drugs_created > 0 {
                (player_nft.successful_crafts * 100) / player_nft.total_drugs_created
            } else {
                0
            };
            
            let experience_tier: ByteArray = if player_nft.experience < 100 { "Novice" }
            else if player_nft.experience < 500 { "Apprentice" }
            else if player_nft.experience < 1000 { "Journeyman" }
            else if player_nft.experience < 2500 { "Expert" }
            else if player_nft.experience < 5000 { "Master" }
            else { "Grandmaster" };
            
            let _reputation_tier: ByteArray = if player_nft.reputation < 100 { "Unknown" }
            else if player_nft.reputation < 300 { "Recognized" }
            else if player_nft.reputation < 600 { "Respected" }
            else if player_nft.reputation < 900 { "Feared" }
            else { "Legendary" };
            
            let enhanced_description = format!(
                "{} player character - Level {}, {} experience, {} reputation, {} drugs created",
                experience_tier,
                player_nft.level,
                player_nft.experience,
                player_nft.reputation,
                player_nft.total_drugs_created
            );

            let metadata = TokenMetadata {
                token_id,
                name: character_name_str,
                description: enhanced_description,
                image: Option::Some(format!("https://dosis.fun/api/character/{}/image", token_id.low)),
                image_data: Option::None,
                external_url: Option::Some(format!("https://dosis.fun/character/{}", token_id.low)),
                background_color: Option::Some("1a1a2e"),
                animation_url: Option::None,
                youtube_url: Option::None,
                attributes: Option::None,
                additional_metadata: Option::None,
            };
            (Option::Some(metadata))
        }
    }

    // Internal burn handling
    #[generate_trait]
    impl InternalBurnImpl of InternalBurnTrait {
        fn _handle_token_burn(self: @ContractState, mut store: Store, token_id: u256) {
            // Get the token owner before cleaning up
            let owner = store.get_token_owner(token_id);

            // 1. Clear UserTokenMapping for the owner
            store.clear_user_token_mapping(owner);

            // 2. Clear TokenOwnerMapping
            store.clear_token_owner_mapping(token_id);

            // 3. Mark PlayerNFT as burned (keep data for historical purposes)
            let mut player_nft = store.read_player_nft(token_id.low.try_into().unwrap());
            if player_nft.is_minted {
                player_nft.is_minted = false;
                player_nft.is_active = false;
                player_nft.owner = constants::ZERO_ADDRESS();
                player_nft.last_active_timestamp = starknet::get_block_timestamp();
                store.write_player_nft(player_nft);
            }
        }
    }

    // Minter access control
    #[generate_trait]
    impl MinterImpl of MinterTrait {
        #[inline(always)]
        fn _assert_caller_is_minter(self: @ContractState, store: @Store) {
            assert(store.world.minter_address() == starknet::get_caller_address(), Errors::CALLER_IS_NOT_MINTER);
        }
    }

    // Admin access control
    #[generate_trait]
    impl AdminImpl of AdminTrait {
        fn _is_contract_admin(self: @ContractState, caller: ContractAddress) -> bool {
            // Check if caller is the contract admin
            self.contract_admin.read() == caller
        }
        
        fn _set_contract_admin(ref self: ContractState, new_admin: ContractAddress) {
            // Only current admin can change admin
            let caller = starknet::get_caller_address();
            assert(self._is_contract_admin(caller), Errors::NOT_ADMIN_OR_OWNER);
            self.contract_admin.write(new_admin);
        }
    }
}
