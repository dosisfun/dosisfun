use dosis_game::models::market::MarketListing;

#[starknet::interface]
pub trait IBlackMarket<T> {
    fn list_drug(ref self: T, nft_token_id: u256, drug_id: u32) -> u32;
    fn cancel_listing(ref self: T, nft_token_id: u256, listing_id: u32);
    fn buy_drug(ref self: T, buyer_nft_token_id: u256, listing_id: u32);
    fn buy_ingredient(ref self: T, nft_token_id: u256, ingredient_id: u32, quantity: u32);
    fn get_listing(ref self: T, listing_id: u32) -> MarketListing;
    fn get_active_listings(ref self: T) -> Array<MarketListing>;
    fn get_seller_listings(ref self: T, nft_token_id: u256) -> Array<MarketListing>;
}

#[dojo::contract]
pub mod black_market_system {
    use dojo::model::ModelStorage;
    use dosis_game::interfaces::dosis_nft::{IDosisNFTDispatcher, IDosisNFTDispatcherTrait};
    use dosis_game::models::nft::DrugRarity;
    use starknet::get_block_timestamp;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use crate::models::market::{AssertTrait, MarketListing};

    #[storage]
    struct Storage {
        listing_counter: u32,
    }

    #[abi(embed_v0)]
    impl BlackMarketImpl of super::IBlackMarket<ContractState> {
        fn list_drug(ref self: ContractState, nft_token_id: u256, drug_id: u32) -> u32 {
            let mut world = self.world(@"dosis_game");

            // Get NFT contract dispatcher
            let nft_contract = IDosisNFTDispatcher { contract_address: 0.try_into().unwrap() };

            // Validate drug ownership and get drug info
            let drug = nft_contract.get_drug(drug_id);
            assert(drug.owner_token_id == nft_token_id, 'Not drug owner');
            assert(!drug.is_locked, 'Drug is locked');

            // Calculate price based on rarity
            let price = calculate_price_by_rarity(drug.rarity);

            // Lock the drug in NFT contract
            nft_contract.lock_drug(drug_id);

            // Create listing
            let listing_id = self.listing_counter.read() + 1;
            self.listing_counter.write(listing_id);

            let listing = MarketListing {
                id: listing_id,
                seller_nft_token_id: nft_token_id,
                drug_id,
                price,
                is_active: true,
                listed_timestamp: get_block_timestamp(),
                sold_timestamp: 0,
                buyer_nft_token_id: 0,
            };

            world.write_model(@listing);
            listing_id
        }

        fn cancel_listing(ref self: ContractState, nft_token_id: u256, listing_id: u32) {
            let mut world = self.world(@"dosis_game");

            // Get listing
            let mut listing: MarketListing = world.read_model(listing_id);
            listing.assert_exists();
            listing.assert_active();

            // Validate ownership
            assert(listing.seller_nft_token_id == nft_token_id, 'Not listing owner');

            // Unlock drug
            let nft_contract = IDosisNFTDispatcher { contract_address: 0.try_into().unwrap() };
            nft_contract.unlock_drug(listing.drug_id);

            // Deactivate listing
            listing.is_active = false;
            world.write_model(@listing);
        }

        fn buy_drug(ref self: ContractState, buyer_nft_token_id: u256, listing_id: u32) {
            let mut world = self.world(@"dosis_game");

            // Get listing
            let mut listing: MarketListing = world.read_model(listing_id);
            listing.assert_exists();
            listing.assert_active();

            // Validate buyer is not seller
            assert(listing.seller_nft_token_id != buyer_nft_token_id, 'Cannot buy own drug');

            let nft_contract = IDosisNFTDispatcher { contract_address: 0.try_into().unwrap() };

            // TODO: Validate and transfer $DOSIS tokens from buyer to seller
            // This will be implemented when ERC20 $DOSIS token is ready
            // For now, we skip this step

            // Get drug info for rewards
            let drug = nft_contract.get_drug(listing.drug_id);

            // Transfer drug ownership
            nft_contract.transfer_drug_ownership(listing.drug_id, buyer_nft_token_id);

            // Unlock drug (now owned by buyer)
            nft_contract.unlock_drug(listing.drug_id);

            // Reward seller with reputation and cash from drug
            nft_contract
                .add_cash_and_reputation(
                    listing.seller_nft_token_id,
                    drug.cash_reward.into(),
                    drug.reputation_reward.try_into().unwrap(),
                );

            // Update listing
            listing.is_active = false;
            listing.sold_timestamp = get_block_timestamp();
            listing.buyer_nft_token_id = buyer_nft_token_id;
            world.write_model(@listing);
        }

        fn get_listing(ref self: ContractState, listing_id: u32) -> MarketListing {
            let mut world = self.world(@"dosis_game");
            let listing: MarketListing = world.read_model(listing_id);
            listing.assert_exists();
            listing
        }

        fn get_active_listings(ref self: ContractState) -> Array<MarketListing> {
            let mut world = self.world(@"dosis_game");
            let mut listings = array![];

            let total_listings = self.listing_counter.read();
            let mut i: u32 = 1;

            while i <= total_listings {
                let listing: MarketListing = world.read_model(i);
                if listing.is_active {
                    listings.append(listing);
                }
                i += 1;
            }

            listings
        }

        fn get_seller_listings(
            ref self: ContractState, nft_token_id: u256,
        ) -> Array<MarketListing> {
            let mut world = self.world(@"dosis_game");
            let mut listings = array![];

            let total_listings = self.listing_counter.read();
            let mut i: u32 = 1;

            while i <= total_listings {
                let listing: MarketListing = world.read_model(i);
                if listing.seller_nft_token_id == nft_token_id {
                    listings.append(listing);
                }
                i += 1;
            }

            listings
        }

        fn buy_ingredient(
            ref self: ContractState, nft_token_id: u256, ingredient_id: u32, quantity: u32,
        ) {
            // Validate quantity
            assert(quantity > 0, 'Quantity must be greater than 0');

            // Calculate total cost
            let unit_price = calculate_ingredient_price(ingredient_id);
            let total_cost = unit_price * quantity.into();

            // Get NFT contract dispatcher
            let nft_contract = IDosisNFTDispatcher { contract_address: 0.try_into().unwrap() };

            // Mint ingredient (this will validate cash and deduct it)
            nft_contract.mint_ingredient(nft_token_id, ingredient_id, quantity, total_cost);
        }
    }

    // Helper function to calculate price based on rarity
    fn calculate_price_by_rarity(rarity: DrugRarity) -> u256 {
        match rarity {
            DrugRarity::Base => 50, // Base: 50 $DOSIS
            DrugRarity::Common => 100, // Common: 100 $DOSIS
            DrugRarity::Rare => 200, // Rare: 200 $DOSIS
            DrugRarity::UltraRare => 350, // UltraRare: 350 $DOSIS
            DrugRarity::Legendary => 500 // Legendary: 500 $DOSIS
        }
    }

    // Helper function to calculate ingredient price based on ID
    fn calculate_ingredient_price(ingredient_id: u32) -> u256 {
        // Prices based on ingredient rarity/type
        // IDs 1-10: Basic ingredients (cheap)
        // IDs 11-20: Intermediate ingredients (medium)
        // IDs 21-30: Advanced ingredients (expensive)
        if ingredient_id <= 10 {
            10 // Basic: 10 cash each
        } else if ingredient_id <= 20 {
            25 // Intermediate: 25 cash each
        } else {
            50 // Advanced: 50 cash each
        }
    }
}
