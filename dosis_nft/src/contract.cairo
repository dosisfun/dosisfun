#[starknet::interface]
trait IDosisNFTContract<TState> {
    // Minting functions
    fn mint(ref self: TState, to: starknet::ContractAddress) -> u256;
    fn mint_batch(ref self: TState, to: starknet::ContractAddress, amount: u256) -> Array<u256>;
    fn mint_to_many(ref self: TState, recipients: Array<starknet::ContractAddress>) -> Array<u256>;

    // Admin functions
    fn set_admin(ref self: TState, new_admin: starknet::ContractAddress);
    fn get_admin(self: @TState) -> starknet::ContractAddress;
    fn set_base_uri(ref self: TState, new_base_uri: ByteArray);
    fn set_contract_uri(ref self: TState, new_contract_uri: ByteArray);
    fn set_minting_paused(ref self: TState, paused: bool);
    
    // Pricing functions
    fn set_mint_price(ref self: TState, price: u256);
    fn get_mint_price(self: @TState) -> u256;
    fn set_treasury_address(ref self: TState, treasury: starknet::ContractAddress);
    fn get_treasury_address(self: @TState) -> starknet::ContractAddress;
    
    // Public mint functions (with payment)
    fn public_mint(ref self: TState) -> u256;
    fn public_mint_to(ref self: TState, to: starknet::ContractAddress) -> u256;

    // View functions (max_supply, total_supply, is_minting_paused, token_exists, etc. are available via ERC721DosisMixinImpl)
}

#[starknet::contract]
mod DosisNFTContract {
    use starknet::{ContractAddress, get_caller_address};
    use core::num::traits::Zero;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use dosis_nft::interfaces::ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};
    
    
    // OpenZeppelin components
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::ERC721Component;
    
    // Dosis components
    use crate::erc721::erc721_dosis::{ERC721DosisComponent, ERC721DosisHooksEmptyImpl};

    // Component declarations
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ERC721DosisComponent, storage: erc721_dosis, event: ERC721DosisEvent);

    // Implementations
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl ERC721DosisInternalImpl = ERC721DosisComponent::InternalImpl<ContractState>;
    impl ERC721DosisHooksImpl = ERC721DosisHooksEmptyImpl<ContractState>;
    
    // OpenZeppelin ERC721 hooks (empty implementation)
    impl ERC721HooksImpl = openzeppelin_token::erc721::ERC721HooksEmptyImpl<ContractState>;

    // ABI exposure
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
        admin: ContractAddress,
        // Pricing and treasury
        mint_price: u256,
        treasury_address: ContractAddress,
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

    mod Errors {
        pub const CALLER_NOT_ADMIN: felt252 = 'Caller is not admin';
        pub const INVALID_ADDRESS: felt252 = 'Invalid address';
        pub const MINTING_PAUSED: felt252 = 'Minting is paused';
        pub const MAX_SUPPLY_REACHED: felt252 = 'Max supply reached';
        pub const INSUFFICIENT_PAYMENT: felt252 = 'Insufficient payment';
        pub const PAYMENT_FAILED: felt252 = 'Payment transfer failed';
    }
    
    // STRK token address on Starknet
    const STRK_ADDRESS: felt252 = 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d;

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: Option<ByteArray>,
        contract_uri: Option<ByteArray>,
        max_supply: Option<u256>,
        admin: ContractAddress,
        mint_price: u256,
        treasury_address: ContractAddress,
    ) {
        // Initialize the ERC721DosisComponent
        self.erc721_dosis.initializer(name, symbol, base_uri, contract_uri, max_supply);
        
        // Set admin
        assert(!admin.is_zero(), Errors::INVALID_ADDRESS);
        self.admin.write(admin);
        
        // Set pricing and treasury
        self.mint_price.write(mint_price);
        assert(!treasury_address.is_zero(), Errors::INVALID_ADDRESS);
        self.treasury_address.write(treasury_address);
    }

    #[abi(embed_v0)]
    impl DosisNFTContractImpl of super::IDosisNFTContract<ContractState> {
        // Minting functions
        fn mint(ref self: ContractState, to: ContractAddress) -> u256 {
            self._assert_only_admin();
            assert(!self.erc721_dosis.is_minting_paused(), Errors::MINTING_PAUSED);
            
            self.erc721_dosis._mint_next(to)
        }

        fn mint_batch(ref self: ContractState, to: ContractAddress, amount: u256) -> Array<u256> {
            self._assert_only_admin();
            assert(!self.erc721_dosis.is_minting_paused(), Errors::MINTING_PAUSED);
            
            let mut token_ids = ArrayTrait::new();
            let mut i = 0;
            
            while i != amount {
                let token_id = self.erc721_dosis._mint_next(to);
                token_ids.append(token_id);
                i += 1;
            };
            
            token_ids
        }

        fn mint_to_many(ref self: ContractState, recipients: Array<ContractAddress>) -> Array<u256> {
            self._assert_only_admin();
            assert(!self.erc721_dosis.is_minting_paused(), Errors::MINTING_PAUSED);
            
            let mut token_ids = ArrayTrait::new();
            let mut i = 0;
            
            while i != recipients.len() {
                let token_id = self.erc721_dosis._mint_next(*recipients.at(i));
                token_ids.append(token_id);
                i += 1;
            };
            
            token_ids
        }

        // Admin functions
        fn set_admin(ref self: ContractState, new_admin: ContractAddress) {
            self._assert_only_admin();
            assert(!new_admin.is_zero(), Errors::INVALID_ADDRESS);
            self.admin.write(new_admin);
        }

        fn get_admin(self: @ContractState) -> ContractAddress {
            self.admin.read()
        }

        fn set_base_uri(ref self: ContractState, new_base_uri: ByteArray) {
            self._assert_only_admin();
            // Base URI is managed by OpenZeppelin ERC721 component
            // The ERC721DosisComponent uses hooks for token_uri rendering
        }

        fn set_contract_uri(ref self: ContractState, new_contract_uri: ByteArray) {
            self._assert_only_admin();
            self.erc721_dosis._set_contract_uri(Option::Some(new_contract_uri));
        }

        fn set_minting_paused(ref self: ContractState, paused: bool) {
            self._assert_only_admin();
            self.erc721_dosis._set_minting_paused(paused);
        }

        // Pricing functions
        fn set_mint_price(ref self: ContractState, price: u256) {
            self._assert_only_admin();
            self.mint_price.write(price);
        }

        fn get_mint_price(self: @ContractState) -> u256 {
            self.mint_price.read()
        }

        fn set_treasury_address(ref self: ContractState, treasury: ContractAddress) {
            self._assert_only_admin();
            assert(!treasury.is_zero(), Errors::INVALID_ADDRESS);
            self.treasury_address.write(treasury);
        }

        fn get_treasury_address(self: @ContractState) -> ContractAddress {
            self.treasury_address.read()
        }

        // Public mint functions (with payment)
        fn public_mint(ref self: ContractState) -> u256 {
            let caller = get_caller_address();
            self.public_mint_to(caller)
        }

        fn public_mint_to(ref self: ContractState, to: ContractAddress) -> u256 {
            assert(!self.erc721_dosis.is_minting_paused(), Errors::MINTING_PAUSED);
            
            let caller = get_caller_address();
            let mint_price = self.mint_price.read();
            let treasury = self.treasury_address.read();
            
            // Handle payment if price > 0
            if mint_price > 0 {
                self._handle_payment(caller, treasury, mint_price);
            }
            
            // Mint the NFT
            self.erc721_dosis._mint_next(to)
        }

        // View functions like token_exists, max_supply, total_supply, etc.
        // are available via ERC721DosisMixinImpl
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _assert_only_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.admin.read(), Errors::CALLER_NOT_ADMIN);
        }

        fn _handle_payment(self: @ContractState, payer: ContractAddress, treasury: ContractAddress, amount: u256) {
            // Create STRK token dispatcher
            let strk_address: ContractAddress = STRK_ADDRESS.try_into().unwrap();
            let erc20_dispatcher = IERC20Dispatcher { contract_address: strk_address };
            
            // Check allowance
            let allowance = erc20_dispatcher.allowance(payer, starknet::get_contract_address());
            assert(allowance >= amount, Errors::INSUFFICIENT_PAYMENT);
            
            // Transfer STRK from payer to treasury
            let success = erc20_dispatcher.transfer_from(payer, treasury, amount);
            assert(success, Errors::PAYMENT_FAILED);
        }
    }
}
