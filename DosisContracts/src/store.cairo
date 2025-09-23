use dosis_game::models::player::{Player, PlayerAssert};
use dosis_game::models::drug::{Drug, DrugAssert, DrugInventory};
use dosis_game::models::recipe::{Recipe, RecipeAssert};
use dosis_game::models::nft::{PlayerNFT, PlayerNFTAssert, ZeroablePlayerNFTTrait, NFTBalance, NFTApproval, NFTOperatorApproval, NFTTokenIndex, NFTOwnerTokenIndex, PlayerNFTCollection};
use dosis_game::helpers::experience_utils::ExperienceCalculator;
use dojo::model::ModelStorage;
use dojo::world::WorldStorage;
use starknet::ContractAddress;

#[derive(Drop, Copy)]
struct Store {
    world: WorldStorage,
}

#[generate_trait]
pub impl StoreImpl of StoreTrait {
    fn new(world: WorldStorage) -> Store {
        Store { world: world }
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

    // [ NFT Player Character methods ]
    fn read_player_nft(self: @Store, token_id: u256) -> PlayerNFT {
        self.world.read_model((token_id))
    }

    fn write_player_nft(ref self: Store, player_nft: PlayerNFT) {
        self.world.write_model(@player_nft)
    }

    fn get_player_character_by_owner(self: @Store, owner: ContractAddress) -> PlayerNFT {
        // Fast-path: no balance, no NFT
        let balance = self.read_nft_balance(owner);
        if balance.balance == 0 {
            return ZeroablePlayerNFTTrait::zero();
        }

        // Use owner->index mapping (index 0) instead of linear scan
        let owner_index = self.read_nft_owner_token_index(owner, 0);
        if owner_index.token_id == 0 {
            return ZeroablePlayerNFTTrait::zero();
        }

        self.read_player_nft(owner_index.token_id)
    }

    // [ NFT Balance methods ]
    fn read_nft_balance(self: @Store, owner: ContractAddress) -> NFTBalance {
        self.world.read_model((owner))
    }

    fn write_nft_balance(ref self: Store, balance: NFTBalance) {
        self.world.write_model(@balance)
    }

    // [ NFT Approval methods ]
    fn read_nft_approval(self: @Store, token_id: u256) -> NFTApproval {
        self.world.read_model((token_id))
    }

    fn write_nft_approval(ref self: Store, approval: NFTApproval) {
        self.world.write_model(@approval)
    }

    // [ NFT Operator Approval methods ]
    fn read_nft_operator_approval(self: @Store, owner: ContractAddress, operator: ContractAddress) -> NFTOperatorApproval {
        self.world.read_model((owner, operator))
    }

    fn write_nft_operator_approval(ref self: Store, operator_approval: NFTOperatorApproval) {
        self.world.write_model(@operator_approval)
    }

    // [ NFT Token Index methods ]
    fn read_nft_token_index(self: @Store, index: u256) -> NFTTokenIndex {
        self.world.read_model((index))
    }

    fn write_nft_token_index(ref self: Store, token_index: NFTTokenIndex) {
        self.world.write_model(@token_index)
    }

    // [ NFT Owner Token Index methods ]
    fn read_nft_owner_token_index(self: @Store, owner: ContractAddress, index: u256) -> NFTOwnerTokenIndex {
        self.world.read_model((owner, index))
    }

    fn write_nft_owner_token_index(ref self: Store, owner_token_index: NFTOwnerTokenIndex) {
        self.world.write_model(@owner_token_index)
    }

    // [ NFT Collection methods ]
    fn read_player_nft_collection(self: @Store) -> PlayerNFTCollection {
        self.world.read_model((1)) // collection_id is always 1
    }

    fn write_player_nft_collection(ref self: Store, collection: PlayerNFTCollection) {
        self.world.write_model(@collection)
    }
}