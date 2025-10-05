#[starknet::interface]
pub trait IDrugCrafting<T> {
    fn craft_drug(ref self: T, recipe_id: u32) -> u32;
}

#[dojo::contract]
pub mod drug_crafting_system {
    use starknet::get_caller_address;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use crate::store::{Store, StoreTrait};
    use super::IDrugCrafting;

    #[abi(embed_v0)]
    impl DrugCraftingImpl of IDrugCrafting<ContractState> {
        fn craft_drug(ref self: ContractState, recipe_id: u32) -> u32 {
            let mut world = self.world(@"dosis_game");
            let mut store = StoreTrait::new(world);
            let caller = get_caller_address();
            1
        }
    }
}
