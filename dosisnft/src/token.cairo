// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts for Cairo ^2.0.0

const DEFAULT_ADMIN_ROLE: felt252 = selector!("DEFAULT_ADMIN_ROLE");
const STATS_UPDATER_ROLE: felt252 = selector!("STATS_UPDATER_ROLE");

#[starknet::contract]
mod MyToken {
    use openzeppelin::access::accesscontrol::AccessControlComponent;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::security::pausable::PausableComponent;
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin::token::erc721::ERC721Component;
    use openzeppelin::token::erc721::interface::{IERC721Metadata, IERC721MetadataCamelOnly};
    use openzeppelin::upgrades::UpgradeableComponent;
    use openzeppelin::upgrades::interface::IUpgradeable;
    use starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };
    use starknet::{ClassHash, ContractAddress, get_caller_address};
    use crate::formater::create_metadata;
    use crate::models::CharacterStats;
    use super::{DEFAULT_ADMIN_ROLE, STATS_UPDATER_ROLE};

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: PausableComponent, storage: pausable, event: PausableEvent);
    component!(path: AccessControlComponent, storage: accesscontrol, event: AccessControlEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);

    // External

    // ERC721Mixin can't be used since we have a custom implementation for Metadata
    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl PausableImpl = PausableComponent::PausableImpl<ContractState>;
    #[abi(embed_v0)]
    impl AccessControlImpl =
        AccessControlComponent::AccessControlImpl<ContractState>;
    #[abi(embed_v0)]
    impl AccessControlCamelImpl =
        AccessControlComponent::AccessControlCamelImpl<ContractState>;
    #[abi(embed_v0)]
    impl AccessControlWithDelayImpl =
        AccessControlComponent::AccessControlWithDelayImpl<ContractState>;

    // Internal
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl PausableInternalImpl = PausableComponent::InternalImpl<ContractState>;
    impl AccessControlInternalImpl = AccessControlComponent::InternalImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        pausable: PausableComponent::Storage,
        #[substorage(v0)]
        accesscontrol: AccessControlComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        characters_stats: Map<u256, CharacterStats>,
        mint_price: u256,
        treasury_address: ContractAddress,
        total_supply: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        PausableEvent: PausableComponent::Event,
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
    }

    mod Errors {
        pub const INSUFFICIENT_PAYMENT: felt252 = 'Insufficient payment';
        pub const PAYMENT_FAILED: felt252 = 'Payment transfer failed';
    }
    
    const STRK_ADDRESS: felt252 =
        0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d;

    #[constructor]
    fn constructor(
        ref self: ContractState,
        default_admin: ContractAddress,
        stats_updater: ContractAddress,
        mint_price: u256,
        treasury_address: ContractAddress,
    ) {
        self.erc721.initializer("DOSIS", "DOSIS", "https://i.postimg.cc/9F8zT4Bc/");
        self.accesscontrol.initializer();

        self.accesscontrol._grant_role(DEFAULT_ADMIN_ROLE, default_admin);
        self.accesscontrol._grant_role(STATS_UPDATER_ROLE, stats_updater);

        self.mint_price.write(mint_price);
        self.treasury_address.write(treasury_address);
    }

    impl ERC721HooksImpl of ERC721Component::ERC721HooksTrait<ContractState> {
        fn before_update(
            ref self: ERC721Component::ComponentState<ContractState>,
            to: ContractAddress,
            token_id: u256,
            auth: ContractAddress,
        ) {
            let mut contract_state = self.get_contract_mut();
            contract_state.pausable.assert_not_paused();
        }
    }

    #[abi(embed_v0)]
    impl ERC721CustomMetadataImpl of IERC721Metadata<ContractState> {
        fn name(self: @ContractState) -> ByteArray {
            self.erc721.name()
        }

        fn symbol(self: @ContractState) -> ByteArray {
            self.erc721.symbol()
        }

        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            let base_uri = self.erc721._base_uri();
            let character_stats = self.characters_stats.entry(token_id).read();
            create_metadata(character_stats, token_id, base_uri)
        }
    }

    #[abi(embed_v0)]
    impl ERC721CustomMetadataCamelOnlyImpl of IERC721MetadataCamelOnly<ContractState> {
        fn tokenURI(self: @ContractState, tokenId: u256) -> ByteArray {
            self.token_uri(tokenId)
        }
    }

    #[generate_trait]
    #[abi(per_item)]
    impl ExternalImpl of ExternalTrait {
        #[external(v0)]
        fn pause(ref self: ContractState) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);
            self.pausable.pause();
        }

        #[external(v0)]
        fn unpause(ref self: ContractState) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);
            self.pausable.unpause();
        }

        #[external(v0)]
        fn mint(ref self: ContractState, to: ContractAddress) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);

            let total_supply = self.total_supply.read();
            let token_id = total_supply + 1;
            self.total_supply.write(token_id);

            self.erc721.safe_mint(to, token_id, [].span());

            self.characters_stats.entry(token_id).write(CharacterStats {
                owner: to,
                character_name: "Soy yo el pepo",
                level: 10,
                experience: 20,
                reputation: 100,
                total_drugs_created: 22,
                successful_crafts: 12,
                failed_crafts: 0,
                creation_timestamp: 0,
                last_active_timestamp: 0,
                is_minted: true,
                is_active: true
            });
        }

        #[external(v0)]
        fn public_mint(ref self: ContractState) {
            let caller = get_caller_address();
            self.public_mint_to(caller)
        }

        #[external(v0)]
        fn public_mint_to(ref self: ContractState, to: ContractAddress) {
            let caller = get_caller_address();
            let mint_price = self.mint_price.read();
            let treasury = self.treasury_address.read();

            if mint_price > 0 {
                let strk_address: ContractAddress = STRK_ADDRESS.try_into().unwrap();
                let erc20_dispatcher = IERC20Dispatcher { contract_address: strk_address };

                let allowance = erc20_dispatcher
                    .allowance(caller, starknet::get_contract_address());
                assert(allowance >= mint_price, Errors::INSUFFICIENT_PAYMENT);

                let success = erc20_dispatcher.transfer_from(caller, treasury, mint_price);
                assert(success, Errors::PAYMENT_FAILED);
            }

            let total_supply = self.total_supply.read();
            let token_id = total_supply + 1;
            self.total_supply.write(token_id);

            self.erc721.safe_mint(to, token_id, [].span())
        }

        #[external(v0)]
        fn set_mint_price(ref self: ContractState, price: u256) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);
            self.mint_price.write(price);
        }

        #[external(v0)]
        fn get_mint_price(self: @ContractState) -> u256 {
            self.mint_price.read()
        }

        #[external(v0)]
        fn set_treasury_address(ref self: ContractState, treasury: ContractAddress) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);
            self.treasury_address.write(treasury);
        }

        #[external(v0)]
        fn get_treasury_address(self: @ContractState) -> ContractAddress {
            self.treasury_address.read()
        }

        #[external(v0)]
        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        #[external(v0)]
        fn get_character_stats(self: @ContractState, token_id: u256) -> CharacterStats {
            self.characters_stats.entry(token_id).read()
        }
    }

    //
    // Upgradeable
    //

    #[abi(embed_v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.accesscontrol.assert_only_role(DEFAULT_ADMIN_ROLE);
            self.upgradeable.upgrade(new_class_hash);
        }
    }
}
