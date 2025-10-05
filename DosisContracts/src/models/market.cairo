#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct MarketListing {
    #[key]
    pub id: u32,
    pub seller_nft_token_id: u256,
    pub drug_id: u32,
    pub price: u256,
    pub is_active: bool,
    pub listed_timestamp: u64,
    pub sold_timestamp: u64,
    pub buyer_nft_token_id: u256 // 0 if not sold
}

#[generate_trait]
pub impl MarketListingAssert of AssertTrait {
    #[inline(always)]
    fn assert_exists(self: MarketListing) {
        assert(self.id > 0, 'Listing: Does not exist');
    }

    #[inline(always)]
    fn assert_active(self: MarketListing) {
        assert(self.is_active, 'Listing: Not active');
    }
}
