use dojo::model::ModelStorage;
use dojo::world::WorldStorage;

#[derive(Drop, Copy)]
pub struct Store {
    pub world: WorldStorage,
}

#[generate_trait]
pub impl StoreImpl of StoreTrait {
    fn new(world: WorldStorage) -> Store {
        Store { world }
    }
}
