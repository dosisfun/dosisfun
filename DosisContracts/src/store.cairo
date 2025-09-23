use dosis_game::models::player::{Player, PlayerAssert};
use dosis_game::models::drug::{Drug, DrugAssert, DrugInventory};
use dosis_game::models::recipe::{Recipe, RecipeAssert};
use dosis_game::models::nft::{PlayerNFT, PlayerNFTAssert, ZeroablePlayerNFTTrait, UserTokenMapping, TokenOwnerMapping};
use dosis_game::helpers::experience_utils::ExperienceCalculator;
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use starknet::{ContractAddress, get_block_timestamp};

#[derive(Drop, Copy)]
pub struct Store {
    pub world: WorldStorage,
}

#[generate_trait]
pub impl StoreImpl of StoreTrait {
    fn new(world: WorldStorage) -> Store {
        Store { world }
    }

    // [ Player methods ]
    fn read_player(self: @Store) -> Player {
        self.read_player_from_address(starknet::get_caller_address())
    }

    fn read_player_from_address(self: @Store, player_address: ContractAddress) -> Player {
        self.world.read_model((player_address))
    }

    fn write_player(ref self: Store, player: Player) {
        self.world.write_model(@player)
    }

    // [ Drug methods ]
    fn read_drug(self: @Store, drug_id: u32) -> Drug {
        self.world.read_model((drug_id))
    }

    fn write_drug(ref self: Store, drug: Drug) {
        self.world.write_model(@drug)
    }

    // [ Drug Inventory methods ]
    fn read_drug_inventory(self: @Store) -> DrugInventory {
        self.world.read_model((starknet::get_caller_address()))
    }

    fn write_drug_inventory(ref self: Store, inventory: DrugInventory) {
        self.world.write_model(@inventory)
    }

    // [ Recipe methods ]
    fn read_recipe(self: @Store, recipe_id: u32) -> Recipe {
        self.world.read_model((recipe_id))
    }

    fn write_recipe(ref self: Store, recipe: Recipe) {
        self.world.write_model(@recipe)
    }

    // [ PlayerNFT methods ]
    fn read_player_nft(self: @Store, token_id: u128) -> PlayerNFT {
        self.world.read_model((token_id))
    }

    fn write_player_nft(ref self: Store, player_nft: PlayerNFT) {
        self.world.write_model(@player_nft)
    }

    // Get player NFT by owner address using proper mapping
    fn get_player_character_by_owner(self: @Store, owner: ContractAddress) -> PlayerNFT {
        let token_id = self.get_user_primary_token_id(owner);
        if token_id > 0 {
            self.read_player_nft(token_id.low.try_into().unwrap())
        } else {
            ZeroablePlayerNFTTrait::zero()
        }
    }

    // Get user's primary token_id using proper mapping
    fn get_user_primary_token_id(self: @Store, user_address: ContractAddress) -> u256 {
        let mapping: UserTokenMapping = self.world.read_model((user_address));
        if mapping.is_primary {
            mapping.token_id
        } else {
            0
        }
    }

    // Set user's primary token when minting
    fn set_user_primary_token(ref self: Store, user_address: ContractAddress, token_id: u256) {
        let user_mapping = UserTokenMapping {
            user_address,
            token_id,
            is_primary: true,
        };
        self.world.write_model(@user_mapping);

        let token_mapping = TokenOwnerMapping {
            token_id,
            owner_address: user_address,
            mint_timestamp: get_block_timestamp(),
        };
        self.world.write_model(@token_mapping);
    }

    // Get token owner using proper mapping
    fn get_token_owner(self: @Store, token_id: u256) -> ContractAddress {
        let mapping: TokenOwnerMapping = self.world.read_model((token_id));
        mapping.owner_address
    }

    // Update token ownership (for transfers)
    fn update_token_ownership(ref self: Store, token_id: u256, new_owner: ContractAddress) {
        // Update token->owner mapping
        let mut token_mapping: TokenOwnerMapping = self.world.read_model((token_id));
        let old_owner = token_mapping.owner_address;
        token_mapping.owner_address = new_owner;
        self.world.write_model(@token_mapping);

        // Clear old user's primary token if this was their primary
        let old_user_mapping: UserTokenMapping = self.world.read_model((old_owner));
        if old_user_mapping.token_id == token_id && old_user_mapping.is_primary {
            let cleared_mapping = UserTokenMapping {
                user_address: old_owner,
                token_id: 0,
                is_primary: false,
            };
            self.world.write_model(@cleared_mapping);
        }

        // Set as new user's primary token (assuming one token per user policy)
        self.set_user_primary_token(new_owner, token_id);
    }

    // Clear user's token mapping (for burn)
    fn clear_user_token_mapping(ref self: Store, user_address: ContractAddress) {
        let cleared_mapping = UserTokenMapping {
            user_address,
            token_id: 0,
            is_primary: false,
        };
        self.world.write_model(@cleared_mapping);
    }

    // Clear token owner mapping (for burn)
    fn clear_token_owner_mapping(ref self: Store, token_id: u256) {
        let cleared_mapping = TokenOwnerMapping {
            token_id,
            owner_address: 0.try_into().unwrap(), // ZERO_ADDRESS
            mint_timestamp: 0,
        };
        self.world.write_model(@cleared_mapping);
    }

    // [ Game logic methods ]
    fn award_experience(ref self: Store, exp_amount: u16) -> bool {
        let mut player = self.read_player();
        
        // Add experience
        player.experience += exp_amount;
        
        // Check if level up is needed
        let exp_needed = ExperienceCalculator::calculate_exp_needed_for_level(player.level);
        let level_up_occurred = player.experience >= exp_needed;
        
        if level_up_occurred {
            // Calculate remaining exp
            player.experience = ExperienceCalculator::remaining_exp_after_level_up(
                player.level, player.experience
            );
            player.level += 1;
            
            // Award reputation for leveling up
            player.reputation += 10;
        }
        
        self.write_player(player);
        level_up_occurred
    }

    fn update_player_crafting_stats(ref self: Store, success: bool) {
        let mut player = self.read_player();
        
        if success {
            player.successful_crafts += 1;
        } else {
            player.failed_crafts += 1;
        }
        
        player.last_active_timestamp = starknet::get_block_timestamp();
        self.write_player(player);
    }

    fn add_drug_to_inventory(ref self: Store, drug_id: u32) {
        let mut inventory = self.read_drug_inventory();
        let mut drug_ids_array = ArrayTrait::new();
        for id in inventory.drug_ids {
            drug_ids_array.append(*id);
        };
        drug_ids_array.append(drug_id);
        inventory.drug_ids = drug_ids_array.span();
        inventory.total_drugs += 1;
        self.write_drug_inventory(inventory);
    }

    fn remove_drug_from_inventory(ref self: Store, drug_id: u32) {
        let mut inventory = self.read_drug_inventory();
        let mut new_drug_ids = ArrayTrait::new();
        
        for drug_id_item in inventory.drug_ids {
            if *drug_id_item != drug_id {
                new_drug_ids.append(*drug_id_item);
            }
        };
        
        inventory.drug_ids = new_drug_ids.span();
        inventory.total_drugs -= 1;
        self.write_drug_inventory(inventory);
    }

    fn get_player_drugs(self: @Store) -> Array<u32> {
        let inventory = self.read_drug_inventory();
        let mut drug_ids_array = ArrayTrait::new();
        for id in inventory.drug_ids {
            drug_ids_array.append(*id);
        };
        drug_ids_array
    }

    fn get_player_stats(self: @Store) -> (u8, u16, u32, u32, u32, u16) {
        let player = self.read_player();
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