use starknet::ContractAddress;

#[starknet::interface]
pub trait IMinter<TState> {
    fn get_price(self: @TState) -> (ContractAddress, u128);
    fn can_mint(self: @TState, spender: ContractAddress, recipient: ContractAddress) -> Option<ByteArray>;
    fn mint(ref self: TState) -> u256;
    fn mint_to(ref self: TState, recipient: ContractAddress, character_name: felt252) -> u256;

    // admin
    fn set_purchase_price(ref self: TState, purchase_coin_address: ContractAddress, purchase_price_strk: u8);
    fn set_treasury_address(ref self: TState, treasury_address: ContractAddress);
    fn set_max_per_wallet(ref self: TState, max_per_wallet: u8);
    fn set_minting_paused(ref self: TState, is_paused: bool);
    fn get_minter_config(self: @TState) -> (ContractAddress, ContractAddress, u128, u8, bool);
}

#[dojo::contract]
pub mod minter {
    use core::num::traits::Zero;
    use starknet::ContractAddress;
    use dojo::world::{WorldStorage, IWorldDispatcherTrait};

    use dosis_game::systems::player_token::{IPlayerTokenDispatcher, IPlayerTokenDispatcherTrait};
    use dosis_game::interfaces::ierc20::{IERC20DispatcherTrait};
    use dosis_game::store::{Store, StoreTrait};
    use dosis_game::models::token_config::{TokenConfig, TokenConfigTrait, ZeroableTokenConfigTrait};
    use dosis_game::libs::dns::{DnsTrait, SELECTORS};
    use dosis_game::utils::hash::make_seed;
    
    mod Errors {
        pub const CALLER_IS_NOT_OWNER: felt252 = 'MINTER: caller is not owner';
        pub const INVALID_TREASURY_ADDRESS: felt252 = 'MINTER: invalid treasury';
        pub const INVALID_COIN_ADDRESS: felt252 = 'MINTER: invalid coin address';
        pub const MINTING_PAUSED: felt252 = 'MINTER: mint paused';
        pub const MINTED_MAXIMUM: felt252 = 'MINTER: minted maximum';
        pub const INVALID_RECEIVER: felt252 = 'MINTER: invalid receiver';
        pub const INSUFFICIENT_ALLOWANCE: felt252 = 'MINTER: insufficient allowance';
        pub const INSUFFICIENT_BALANCE: felt252 = 'MINTER: insufficient balance';
        pub const INVALID_CHARACTER_NAME: felt252 = 'MINTER: invalid character name';
        pub const SUPPLY_EXCEEDED: felt252 = 'MINTER: supply exceeded';
    }

    //---------------------------------------
    // Initialization with default config
    //
    fn dojo_init(ref self: ContractState,
        treasury_address: ContractAddress,
        purchase_coin_address: ContractAddress, // STRK, USDC, etc.
        purchase_price_strk: u8, // Price in STRK (will be converted to wei)
    ) {
        let mut store: Store = StoreTrait::new(self.world_default());
        assert(!treasury_address.is_zero(), Errors::INVALID_TREASURY_ADDRESS);
        
        // Get player_token address dynamically from DNS
        let player_token_address = store.world.player_token_address();
        
        // Create initial token configuration
        let mut config = ZeroableTokenConfigTrait::zero();
        config.token_address = player_token_address;
        config.treasury_address = treasury_address;
        config.purchase_coin_address = purchase_coin_address;
        config.set_price_strk(purchase_price_strk.into());
        config.max_per_wallet = 1; // Default: 1 NFT per wallet
        config.is_minting_paused = false;
        
        store.set_token_config(@config);
    }

    #[generate_trait]
    impl WorldDefaultImpl of WorldDefaultTrait {
        #[inline(always)]
        fn world_default(self: @ContractState) -> WorldStorage {
            self.world(@"dosis_game")
        }
    }

    //---------------------------------------
    // IMinter Implementation
    //
    #[abi(embed_v0)]
    impl MinterImpl of super::IMinter<ContractState> {
        fn get_price(self: @ContractState) -> (ContractAddress, u128) {
            let store: Store = StoreTrait::new(self.world_default());
            let config = self._get_player_token_config(@store);
            (config.purchase_coin_address, config.purchase_price_wei)
        }

        fn can_mint(self: @ContractState, spender: ContractAddress, recipient: ContractAddress) -> Option<ByteArray> {
            let store: Store = StoreTrait::new(self.world_default());
            let config = self._get_player_token_config(@store);
            let _player_token_dispatcher = self._get_player_token_dispatcher();
            
            // Check global minting pause
            if config.is_minting_paused {
                return Option::Some("Minting is paused");
            }
            
            // Check if max supply reached (use store to check balance)
            if store.get_player_nft_balance(recipient, config.token_address) >= config.max_per_wallet.into() {
                return Option::Some("Max per wallet reached");
            }
            
            // Check if payment is required and user has sufficient balance
            if config.has_payment_configured() {
                let coin_dispatcher = config.purchase_coin_dispatcher();
                let required_amount: u256 = config.purchase_price_wei.into();
                
                // Check balance
                if coin_dispatcher.balance_of(spender) < required_amount {
                    return Option::Some("Insufficient balance");
                }
                
                // Check allowance
                let contract_address = starknet::get_contract_address();
                if coin_dispatcher.allowance(spender, contract_address) < required_amount {
                    return Option::Some("Insufficient allowance");
                }
            }
            
            // All checks passed
            Option::None
        }

        fn mint(ref self: ContractState) -> u256 {
            let caller = starknet::get_caller_address();
            // Generate a default character name based on address
            let character_name: felt252 = 'DefaultPlayer';
            self.mint_to(caller, character_name)
        }

        fn mint_to(ref self: ContractState, recipient: ContractAddress, character_name: felt252) -> u256 {
            // Validate character name
            assert(character_name != '', Errors::INVALID_CHARACTER_NAME);
            
            let caller = starknet::get_caller_address();
            let mut store: Store = StoreTrait::new(self.world_default());
            let config = self._get_player_token_config(@store);
            let player_token_dispatcher = self._get_player_token_dispatcher();
            
            // Check if caller can mint (only if not contract owner)
            if !self._caller_is_owner() {
                // Check minting rules
                assert(!config.is_minting_paused, Errors::MINTING_PAUSED);
                assert(config.account_can_mint(@store, recipient, config.token_address), Errors::MINTED_MAXIMUM);

                // Process payment if configured
                if config.has_payment_configured() {
                    self._process_payment(@config, caller, ref store);
                }
            }

            // Generate seed for character attributes using current timestamp and recipient
            let seed = make_seed(recipient, starknet::get_block_timestamp().into());

            // Mint the NFT through player_token contract
            let token_id = player_token_dispatcher.mint_player_character(recipient, character_name);

            // Emit minting event
            store.emit_token_minted_event(
                config.token_address,
                token_id,
                recipient,
                character_name,
                seed,
                config.purchase_coin_address,
                config.purchase_price_wei,
                config.treasury_address
            );

            token_id
        }

        //---------------------------------------
        // Admin functions
        //
        fn set_purchase_price(ref self: ContractState, purchase_coin_address: ContractAddress, purchase_price_strk: u8) {
            self._assert_caller_is_owner();
            let mut store: Store = StoreTrait::new(self.world_default());
            let mut config = self._get_player_token_config(@store);
            
            let old_coin_address = config.purchase_coin_address;
            let old_price_wei = config.purchase_price_wei;
            
            config.purchase_coin_address = purchase_coin_address;
            config.set_price_strk(purchase_price_strk.into());
            
            store.set_token_config(@config);
            
            // Emit price update event
            store.emit_price_updated_event(
                config.token_address,
                old_coin_address,
                purchase_coin_address,
                old_price_wei,
                config.purchase_price_wei,
                starknet::get_caller_address()
            );
        }

        fn set_treasury_address(ref self: ContractState, treasury_address: ContractAddress) {
            self._assert_caller_is_owner();
            assert(!treasury_address.is_zero(), Errors::INVALID_TREASURY_ADDRESS);
            
            let mut store: Store = StoreTrait::new(self.world_default());
            let mut config = self._get_player_token_config(@store);
            config.treasury_address = treasury_address;
            store.set_token_config(@config);
        }

        fn set_max_per_wallet(ref self: ContractState, max_per_wallet: u8) {
            self._assert_caller_is_owner();
            let mut store: Store = StoreTrait::new(self.world_default());
            let mut config = self._get_player_token_config(@store);
            config.max_per_wallet = max_per_wallet;
            store.set_token_config(@config);
        }

        fn set_minting_paused(ref self: ContractState, is_paused: bool) {
            self._assert_caller_is_owner();
            let mut store: Store = StoreTrait::new(self.world_default());
            let mut config = self._get_player_token_config(@store);
            config.is_minting_paused = is_paused;
            store.set_token_config(@config);
            
            // Emit pause event
            store.emit_minting_paused_event(
                config.token_address,
                is_paused,
                starknet::get_caller_address()
            );
        }

        fn get_minter_config(self: @ContractState) -> (ContractAddress, ContractAddress, u128, u8, bool) {
            let store: Store = StoreTrait::new(self.world_default());
            let config = self._get_player_token_config(@store);
            (
                config.treasury_address,
                config.purchase_coin_address,
                config.purchase_price_wei,
                config.max_per_wallet,
                config.is_minting_paused
            )
        }
    }

    //-----------------------------------
    // Internal functions
    //
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _assert_caller_is_owner(self: @ContractState) {
            assert(self._caller_is_owner(), Errors::CALLER_IS_NOT_OWNER);
        }
        
        fn _caller_is_owner(self: @ContractState) -> bool {
            let world = self.world_default();
            world.dispatcher.is_owner(SELECTORS::MINTER, starknet::get_caller_address())
        }
        
        fn _get_player_token_address(self: @ContractState) -> ContractAddress {
            // Get player_token address dynamically from DNS
            let world = self.world_default();
            world.player_token_address()
        }
        
        fn _get_player_token_config(self: @ContractState, store: @Store) -> TokenConfig {
            store.get_token_config(self._get_player_token_address())
        }
        
        fn _get_player_token_dispatcher(self: @ContractState) -> IPlayerTokenDispatcher {
            IPlayerTokenDispatcher { contract_address: self._get_player_token_address() }
        }
        
        fn _process_payment(self: @ContractState, config: @TokenConfig, payer: ContractAddress, ref store: Store) {
            let coin_dispatcher = config.purchase_coin_dispatcher();
            let amount: u256 = (*config.purchase_price_wei).into();
            let contract_address = starknet::get_contract_address();
            
            // Verify balance and allowance (double check)
            assert(coin_dispatcher.balance_of(payer) >= amount, Errors::INSUFFICIENT_BALANCE);
            assert(coin_dispatcher.allowance(payer, contract_address) >= amount, Errors::INSUFFICIENT_ALLOWANCE);
            
            // Execute payment transfer
            assert(!config.treasury_address.is_zero(), Errors::INVALID_RECEIVER);
            let transfer_success = coin_dispatcher.transfer_from(payer, *config.treasury_address, amount);
            assert(transfer_success, 'Transfer failed');
            
            // Emit payment event
            store.emit_payment_received_event(
                *config.treasury_address,
                payer,
                *config.token_address,
                0, // Token ID will be set after minting
                *config.purchase_coin_address,
                *config.purchase_price_wei
            );
        }
    }
}
