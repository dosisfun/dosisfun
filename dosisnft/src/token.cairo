// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts for Cairo ^2.0.0

const DOSIS_CONTRACT_ROLE: felt252 = selector!("DOSIS_CONTRACT_ROLE");
const MINT_ROLE: felt252 = selector!("MINT_ROLE");

#[starknet::contract]
mod MyToken {
    use openzeppelin::access::accesscontrol::{AccessControlComponent, DEFAULT_ADMIN_ROLE};
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
    use crate::models::{CharacterStats, Drug, DrugRarity};
    use super::{DOSIS_CONTRACT_ROLE, MINT_ROLE};

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
        ingredient_counter: u256,
        character_ingredients: Map<(u256, u32), u32>,
        drug_counter: u32,
        drugs: Map<u32, Drug>,
        character_drug_ids: Map<u256, u32>,
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
        pub const INSUFFICIENT_CASH: felt252 = 'Insufficient cash';
        pub const DRUG_NOT_EXIST: felt252 = 'Drug does not exist';
        pub const DRUG_ALREADY_LOCKED: felt252 = 'Drug already locked';
        pub const DRUG_NOT_LOCKED: felt252 = 'Drug not locked';
        pub const DRUG_IS_LOCKED: felt252 = 'Drug is locked';
        pub const INSUFFICIENT_INGREDIENT: felt252 = 'Insufficient ingredient';
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
        self.accesscontrol._grant_role(MINT_ROLE, default_admin);
        self.accesscontrol._grant_role(DOSIS_CONTRACT_ROLE, stats_updater);

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
        fn mint(ref self: ContractState, to: ContractAddress, character_name: ByteArray) {
            self.accesscontrol.assert_only_role(MINT_ROLE);

            let total_supply = self.total_supply.read();
            let token_id = total_supply + 1;
            self.total_supply.write(token_id);

            self.erc721.safe_mint(to, token_id, [].span());

            self
                .characters_stats
                .entry(token_id)
                .write(
                    CharacterStats {
                        owner: to,
                        character_name,
                        cash: 9999999999, // TODO:
                        level: 0,
                        experience: 0,
                        reputation: 0,
                        total_drugs_created: 0,
                        successful_crafts: 0,
                        failed_crafts: 0,
                        creation_timestamp: 0,
                        last_active_timestamp: 0,
                        is_minted: true,
                        is_active: true,
                    },
                );
        }

        #[external(v0)]
        fn public_mint(ref self: ContractState, character_name: ByteArray) {
            let caller = get_caller_address();
            self.public_mint_to(caller, character_name)
        }

        #[external(v0)]
        fn public_mint_to(ref self: ContractState, to: ContractAddress, character_name: ByteArray) {
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

            self.erc721.safe_mint(to, token_id, [].span());

            self
                .characters_stats
                .entry(token_id)
                .write(
                    CharacterStats {
                        owner: to,
                        character_name,
                        cash: 9999999999, // TODO:
                        level: 0,
                        experience: 0,
                        reputation: 0,
                        total_drugs_created: 0,
                        successful_crafts: 0,
                        failed_crafts: 0,
                        creation_timestamp: 0,
                        last_active_timestamp: 0,
                        is_minted: true,
                        is_active: true,
                    },
                );
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

        #[external(v0)]
        fn mint_ingredient(
            ref self: ContractState,
            token_id: u256,
            ingredient_id: u32,
            quantity: u32,
            total_cost: u256,
        ) {
            self.accesscontrol.assert_only_role(DOSIS_CONTRACT_ROLE);

            let mut character_stats = self.characters_stats.entry(token_id).read();
            assert(character_stats.cash >= total_cost, Errors::INSUFFICIENT_CASH);

            character_stats.cash -= total_cost;
            self.characters_stats.entry(token_id).write(character_stats);

            let current_quantity = self
                .character_ingredients
                .entry((token_id, ingredient_id))
                .read();
            self
                .character_ingredients
                .entry((token_id, ingredient_id))
                .write(current_quantity + quantity);

            self.ingredient_counter.write(self.ingredient_counter.read() + 1);
        }

        #[external(v0)]
        fn get_character_ingredient(
            self: @ContractState, token_id: u256, ingredient_id: u32,
        ) -> u32 {
            self.character_ingredients.entry((token_id, ingredient_id)).read()
        }

        #[external(v0)]
        fn get_character_ingredients(
            self: @ContractState, token_id: u256
        ) -> Array<(u32, u32)> {
            let mut ingredients = array![];

            let mut ingredient_id: u32 = 1;
            while ingredient_id <= 5 { // amount of ingredients
                let quantity = self.character_ingredients.entry((token_id, ingredient_id)).read();
                if quantity > 0 {
                    ingredients.append((ingredient_id, quantity));
                }

                ingredient_id += 1;
            }

            ingredients
        }

        #[external(v0)]
        fn mint_drug(
            ref self: ContractState,
            token_id: u256,
            name: ByteArray,
            rarity: DrugRarity,
            reputation_reward: u32,
            cash_reward: u32,
        ) -> u32 {
            self.accesscontrol.assert_only_role(DOSIS_CONTRACT_ROLE);

            let drug_id = self.drug_counter.read() + 1;
            self.drug_counter.write(drug_id);

            let drug = Drug {
                id: drug_id,
                owner_token_id: token_id,
                name,
                rarity,
                reputation_reward,
                cash_reward,
                is_locked: false,
            };

            self.drugs.entry(drug_id).write(drug);

            let current_count = self.character_drug_ids.entry(token_id).read();
            self.character_drug_ids.entry(token_id).write(current_count + 1);

            let mut character_stats = self.characters_stats.entry(token_id).read();
            character_stats.total_drugs_created += 1;
            self.characters_stats.entry(token_id).write(character_stats);

            drug_id
        }

        #[external(v0)]
        fn get_drug(self: @ContractState, drug_id: u32) -> Drug {
            self.drugs.entry(drug_id).read()
        }

        #[external(v0)]
        fn get_character_drug_count(self: @ContractState, token_id: u256) -> u32 {
            self.character_drug_ids.entry(token_id).read()
        }

        #[external(v0)]
        fn get_character_drugs(self: @ContractState, token_id: u256) -> Array<Drug> {
            let mut drugs = array![];
            let total_drugs = self.drug_counter.read();

            let mut i: u32 = 1;
            while i <= total_drugs {
                let drug = self.drugs.entry(i).read();
                if drug.owner_token_id == token_id {
                    drugs.append(drug);
                }
                i += 1;
            }
            drugs
        }

        #[external(v0)]
        fn lock_drug(ref self: ContractState, drug_id: u32) {
            self.accesscontrol.assert_only_role(DOSIS_CONTRACT_ROLE);

            let mut drug = self.drugs.entry(drug_id).read();
            assert(drug.id > 0, Errors::DRUG_NOT_EXIST);
            assert(!drug.is_locked, Errors::DRUG_ALREADY_LOCKED);

            drug.is_locked = true;
            self.drugs.entry(drug_id).write(drug);
        }

        #[external(v0)]
        fn unlock_drug(ref self: ContractState, drug_id: u32) {
            self.accesscontrol.assert_only_role(DOSIS_CONTRACT_ROLE);

            let mut drug = self.drugs.entry(drug_id).read();
            assert(drug.id > 0, Errors::DRUG_NOT_EXIST);
            assert(drug.is_locked, Errors::DRUG_NOT_LOCKED);

            drug.is_locked = false;
            self.drugs.entry(drug_id).write(drug);
        }

        #[external(v0)]
        fn transfer_drug_ownership(
            ref self: ContractState, drug_id: u32, new_owner_token_id: u256,
        ) {
            self.accesscontrol.assert_only_role(DOSIS_CONTRACT_ROLE);

            let mut drug = self.drugs.entry(drug_id).read();
            assert(drug.id > 0, Errors::DRUG_NOT_EXIST);

            let old_owner_token_id = drug.owner_token_id;

            // Update drug ownership
            drug.owner_token_id = new_owner_token_id;
            self.drugs.entry(drug_id).write(drug);

            // Update drug count for old owner
            let old_count = self.character_drug_ids.entry(old_owner_token_id).read();
            if old_count > 0 {
                self.character_drug_ids.entry(old_owner_token_id).write(old_count - 1);
            }

            // Update drug count for new owner
            let new_count = self.character_drug_ids.entry(new_owner_token_id).read();
            self.character_drug_ids.entry(new_owner_token_id).write(new_count + 1);
        }

        #[external(v0)]
        fn consume_ingredient(
            ref self: ContractState, token_id: u256, ingredient_id: u32, quantity: u32,
        ) {
            self.accesscontrol.assert_only_role(DOSIS_CONTRACT_ROLE);

            let current_quantity = self
                .character_ingredients
                .entry((token_id, ingredient_id))
                .read();
            assert(current_quantity >= quantity, Errors::INSUFFICIENT_INGREDIENT);

            self
                .character_ingredients
                .entry((token_id, ingredient_id))
                .write(current_quantity - quantity);
        }

        #[external(v0)]
        fn consume_drug(ref self: ContractState, drug_id: u32) {
            self.accesscontrol.assert_only_role(DOSIS_CONTRACT_ROLE);

            let mut drug = self.drugs.entry(drug_id).read();
            assert(drug.id > 0, Errors::DRUG_NOT_EXIST);
            assert(!drug.is_locked, Errors::DRUG_IS_LOCKED);

            // Remove drug from owner's count
            let owner_count = self.character_drug_ids.entry(drug.owner_token_id).read();
            if owner_count > 0 {
                self.character_drug_ids.entry(drug.owner_token_id).write(owner_count - 1);
            }

            // Delete drug (set to default/zero state)
            let zero_drug = Drug {
                id: 0,
                owner_token_id: 0,
                name: "",
                rarity: DrugRarity::Base,
                reputation_reward: 0,
                cash_reward: 0,
                is_locked: false,
            };
            self.drugs.entry(drug_id).write(zero_drug);
        }

        #[external(v0)]
        fn update_character_stats(
            ref self: ContractState,
            token_id: u256,
            cash: u256,
            level: u8,
            experience: u16,
            reputation: u16,
            craft_success: bool,
        ) {
            self.accesscontrol.assert_only_role(DOSIS_CONTRACT_ROLE);

            let mut character_stats = self.characters_stats.entry(token_id).read();

            character_stats.cash += cash;
            character_stats.level += level;
            character_stats.experience += experience;
            character_stats.reputation += experience;

            if craft_success {
                character_stats.successful_crafts += 1;
            } else {
                character_stats.failed_crafts += 1;
            }
            
            character_stats.last_active_timestamp = starknet::get_block_timestamp();

            self.characters_stats.entry(token_id).write(character_stats);
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
