#[derive(Drop, Serde)]
#[dojo::model]
pub struct CraftingSession {
    #[key]
    pub nft_token_id: u256,
    pub drug_name: ByteArray,
    pub total_steps_required: u32,
    pub steps_completed: u32,
    pub started_timestamp: u64,
    pub last_progress_timestamp: u64,
    pub is_active: bool,
}

#[generate_trait]
pub impl CraftingSessionAssert of AssertTrait {
    #[inline(always)]
    fn assert_active(self: @CraftingSession) {
        assert(*self.is_active, 'CraftingSession: Not active');
    }

    #[inline(always)]
    fn assert_not_active(self: @CraftingSession) {
        assert(!*self.is_active, 'CraftingSession: Already active');
    }

    #[inline(always)]
    fn assert_not_completed(self: @CraftingSession) {
        assert(*self.steps_completed < *self.total_steps_required, 'CraftingSession: Completed');
    }
}
